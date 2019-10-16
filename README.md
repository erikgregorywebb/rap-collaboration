# A Brief Study of Collaboration in Rap Music

I love music, especially rap music. In the world of rap, almost nothing beats hearing two or more of your favorite artists team up on a song. A well-placed guest verse can launch a career! Looking to systematically analyze collaboration in rap, I compiled a dataset of 500+ hip-hop artists and x+ tracks to understand which of my favorite rappers enjoy working with each other.

### Visualization
The visual was created using Flourish, a data visualization and storytelling platform. Click here for a live version.

### Methodology
- Create list of rappers and rap groups from [Wikipedia](https://en.wikipedia.org/wiki/List_of_hip_hop_musicians) 
- Scrape [kworb.net](https://kworb.net/spotify/artists.html), a music data site, for list of top 10,000 artists on Spotify
- Use fuzzy match to determine which of the 10K kworb.net artists fell into the Wikipedia-defined rap bucket
- Scrape song-level artist streaming data from [kworb.net](https://kworb.net/spotify/artists.html), which lists any artists featured on a song
- Pivot to calculate “collaboration counts” between artists (which froms the “node” dataset for the network chart)
