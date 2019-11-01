
# set working directory
setwd("~/Files/Projects/rap")

# import libraries
library(tidyverse)
library(rvest)
library(fuzzyjoin)

# The first step was to create a comprehensive list of rappers and rap groups. Luckly, Wikipedia has a page for each: one for hip-hop musicians,and another for hip-hop groups. After scraping (rvest) and combining the names from both pages, there are 2,000+ rappers and rap groups. 

# obtain list of wikipedia 'hip-hop' MUSICIANS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_musicians'
download.file(url, 'page.html')
page = read_html('page.html')
rappers = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% as_data_frame %>%
  rename(name = value) %>% mutate(type = 'musician')

# obtain list of wikipedia 'hip-hop' GROUPS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_groups'
download.file(url, 'page.html')
page = read_html('page.html')
groups = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% as_data_frame %>%
  rename(name = value) %>% mutate(type = 'group')

# merge list of musicians and groups
rapper_list = bind_rows(rappers, groups)

# Show sample table (rapper_list)
rapper_list

# Next, I turned to kworb.net, a music data site, to scrape a list of the top 10,000 artists on Spotify. 

# obtain list of Spotify artists (top 10,000)
url = 'https://kworb.net/spotify/artists.html'
download.file(url, 'page.html')
page = read_html('page.html')
top_artists_raw = page %>% html_nodes("table") %>% html_table(fill = TRUE)
top_artists = top_artists_raw[[1]] %>% as_tibble()

# add links to detailed artist pages
artist_urls = tibble(name = page %>% html_nodes("table") %>% html_nodes('a') %>% html_text(),
                     url = page %>% html_nodes("table") %>% html_nodes('a') %>% html_attr('href'))
top_artists = inner_join(x = top_artists, y = artist_urls, by = c('Artist' = 'name'))

# clean the top artists dataframe
top_artists = top_artists %>%
  mutate(`Total Streams` = as.numeric(gsub(",","", `Total Streams`)))

# Show sample table (top_artists)
top_artists

# Using a fuzzy match from the fuzzyjoin package, I determined which of the 10,000 top artists were rappers or rap groups, based on the list compiled from Wikipedia. Of the orginal 10k artists, 547 rap artists/groups remain. 

# filter to include only rap artists/groups (using a fuzzy match)
top_rap_artists = top_artists %>%
  stringdist_inner_join(rapper_list, by = c(Artist = "name"), max_dist = 1) %>% 
  distinct(Artist, .keep_all = T) %>% select(-name) %>%
  rename(pos = Pos, name = Artist, streams = `Total Streams`) %>%
  mutate(url = paste('https://kworb.net/spotify/', url, sep = ''))

# Show sample table (top_artists)
top_rap_artists

# At this point, we only have a high-level list of today's top rappers and thier total number of track streams on Spotify. (By the way, check out Drake's figure. That's 18 billion with a b) Next, we'll need to compile song-level artist streaming data. Again, we'll turn to kworb.net. The reason I chose kworb.net is that it neatly lists lists any artists featured on a song, which will be key to our quest to understand collobration in the rap game. 

# obtain artist-level tracks, complete with feature details
datalist = list()
for (i in 1:nrow(top_rap_artists)) {
  Sys.sleep(1)
  print(top_rap_artists$name[i])

  # download, import
  url = top_rap_artists$url[i]
  download.file(url, 'page.html')
  artist_page = read_html('page.html')
  
  # extract detial
  artist_table = artist_page %>% html_nodes("table") %>% html_table(fill = TRUE)
  artist_table = artist_table[[1]] %>% as_tibble()
  artist_table = artist_table %>% 
    select(`Peak Date`, Track, With, Streams) %>%
    mutate(Artist = top_rap_artists$name[i])
  
  # combine
  datalist[[i]] = artist_table
}
all_tracks = do.call(rbind, datalist)

# Show sample table (all_tracks)
all_tracks

# Great, now we have the track data, 8,632 rows in total. But there's a problem. Tracks with features are repeated multiple times, based on the number of artists that appear on the song. For example, the star-stacked "Champions" below features 8 rappers. How can we address this?

# Show sample table (duplicate row example)
all_tracks %>% filter(Track == 'Champions')


all_tracks %>%
  filter(With != '') %>%
  #filter(Track == 'One Dance') %>%
  group_by(`Peak Date`, Streams, Track) %>%
  nest(Arist) %>% View()

# Fork 1

# split features into multiple rows
all_tracks_features = all_tracks %>% 
  separate_rows(With, sep = ", ") %>%
  filter(With != '')

# remove duplicates
# source: https://stackoverflow.com/questions/29170099/remove-duplicate-column-pairs-sort-rows-based-on-2-columns?rq=1
all_tracks_features_dedup = all_tracks_features %>%
  rowwise() %>%
  mutate(key = paste(sort(c(With, Arist, Streams)), collapse = "")) %>%
  distinct(key, .keep_all=T) %>%
  select(-key) %>% ungroup()

all_tracks_features_dedup %>%
  group_by(Arist, With) %>%
  count() %>% arrange(desc(n)) %>% View()

all_tracks_features %>% filter(Arist == 'Travis Scott') %>% View()

all_tracks_features_dedup

 # export back-up .csv files
write_csv(rapper_list, 'rapper-list.csv')
write_csv(top_artists, 'top-artists.csv')
write_csv(top_rap_artists, 'top-rap-artists.csv')
