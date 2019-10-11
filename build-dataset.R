# import libraries
library(tidyverse)
library(rvest)
library(fuzzyjoin)

# obtain list of wikipedia 'hip-hop' MUSICIANS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_musicians'
page = read_html(url)
rappers = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% tibble::enframe(name = NULL) %>%
  rename(name = value) %>% mutate(type = 'musician')

# obtain list of wikipedia 'hip-hop' GROUPS
url = 'https://en.wikipedia.org/wiki/List_of_hip_hop_groups'
page = read_html(url)
groups = page %>% 
  html_nodes('.column-width') %>% html_nodes('a') %>% 
  html_text() %>% tibble::enframe(name = NULL) %>%
  rename(name = value) %>% mutate(type = 'group')

# merge list of musicians and groups
rapper_list = bind_rows(rappers, groups)

# obtain list of Spotify artists (top 10,000)
url = 'https://kworb.net/spotify/artists.html'
page = read_html(url)
top_artists_raw = page %>% html_nodes("table") %>% html_table(fill = TRUE)
top_artists = top_artists_raw[[1]] %>% as_tibble()

# add links to detailed artist pages
artist_urls = tibble(name = page %>% html_nodes("table") %>% html_nodes('a') %>% html_text(),
                     url = page %>% html_nodes("table") %>% html_nodes('a') %>% html_attr('href'))
top_artists = inner_join(x = top_artists, y = artist_urls, by = c('Artist' = 'name'))

# clean the top artists dataframe
top_artists = top_artists %>%
  mutate(`Total Streams` = as.numeric(gsub(",","", `Total Streams`)))

# filter to include only rap artists/groups (using a fuzzy match)
top_rap_artists = top_artists %>%
  stringdist_inner_join(rapper_list, by = c(Artist = "name"), max_dist = 1) %>% 
  distinct(Artist, .keep_all = T) %>% select(-name) %>%
  rename(pos = Pos, name = Artist, streams = `Total Streams`) %>%
  mutate(url = paste('https://kworb.net/spotify/', url, sep = ''))

# obtain artist-level tracks, complete with feature details
datalist = list()
for (i in 1:10) {
  Sys.sleep(3)
  print(top_rap_artists$name[i])
  url = top_rap_artists$url[i]
  artist_page = read_html(url)
  artist_table = artist_page %>% html_nodes("table") %>% html_table(fill = TRUE)
  artist_table = artist_table[[1]] %>% as_tibble()
  artist_table = artist_table %>% 
    select(`Peak Date`, Track, With, Streams) %>%
    separate_rows(With, sep = ", ") %>%
    mutate(Arist = top_rap_artists$name[i])
  datalist[[i]] = artist_table
}
all_tracks = do.call(rbind, datalist)

# export back-up .csv files
write_csv(rapper_list, 'rapper-list.csv')
write_csv(top_artists, 'top-artists.csv')
write_csv(top_rap_artists, 'top-rap-artists.csv')
