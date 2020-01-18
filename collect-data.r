setwd("~/projects/rap")

# import libraries
library(tidyverse)
library(rvest)
library(fuzzyjoin)
library(igraph)
library(visNetwork)

# The first step was to create a comprehensive list of rappers and rap groups. 
# Luckly, Wikipedia has a page for each: one for hip-hop musicians,and another for hip-hop groups. 
# After scraping (rvest) and combining the names from both pages, there are 2,000+ rappers and rap groups. 

# obtain list of wikipedia 'hip-hop' MUSICIANS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_musicians'
download.file(url, 'page.html')
page = read_html('page.html')
rappers = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% tibble::enframe(name = 'no') %>%
  rename(name = value) %>% mutate(type = 'musician')

# obtain list of wikipedia 'hip-hop' GROUPS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_groups'
download.file(url, 'page.html')
page = read_html('page.html')
groups = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% tibble::enframe(name = 'no') %>%
  rename(name = value) %>% mutate(type = 'group')

# merge list of musicians and groups
rapper_list = bind_rows(rappers, groups)

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

# Using a fuzzy match from the fuzzyjoin package, 
# I determined which of the 10,000 top artists were rappers or rap groups, 
# based on the list compiled from Wikipedia.

# filter to include only rap artists/groups (using a fuzzy match)
top_rap_artists = top_artists %>%
  stringdist_inner_join(rapper_list, by = c(Artist = "name"), max_dist = 1) %>% 
  distinct(Artist, .keep_all = T) %>% select(-name) %>%
  rename(pos = Pos, name = Artist, streams = `Total Streams`) %>%
  mutate(url = paste('https://kworb.net/spotify/', url, sep = ''))

# obtain artist-level tracks, complete with feature details
datalist = list()
for (i in 1:nrow(top_rap_artists)) {
  Sys.sleep(.5)
  print(top_rap_artists$name[i])
  print(paste(round(i/nrow(top_rap_artists)*100, 2), '%', sep = ''))
  url = top_rap_artists$url[i]
  download.file(url, 'page.html')
  artist_page = read_html('page.html')
  artist_table = artist_page %>% html_nodes("table") %>% html_table(fill = TRUE)
  artist_table = artist_table[[1]] %>% as_tibble()
  artist_table = artist_table %>% 
    select(`Peak Date`, Track, With, Streams) %>%
    separate_rows(With, sep = ", ") %>%
    mutate(Arist = top_rap_artists$name[i])
  datalist[[i]] = artist_table
}
all_tracks_master = do.call(rbind, datalist)
write_csv(all_tracks_master, 'all-tracks.csv')
