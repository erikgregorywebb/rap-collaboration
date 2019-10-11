# A Brief Study of Collaboration in Rap Music

I love music, especially rap music. In the world of rap, almost nothing beats hearing two or more of your favorite artists team up on a song. A well-placed guest verse can launch a career (link)! Looking to systematically analyze collaboration in rap, I compiled a dataset of 500+ hip-hop artists and x+ tracks to understand which of my favorite rappers enjoy working with each other. 

### Visualization

### Methodology
I first created a list of [rappers](https://en.wikipedia.org/wiki/List_of_hip_hop_musicians) and [rap groups](https://en.wikipedia.org/wiki/List_of_hip_hop_groups) from Wikipedia. I then scrapped [kworb.net](https://kworb.net/spotify/artists.html), a music data site, for a list of the top 10,000 artists on Spotify. In order to determine which of the 10K artists fell into the rap bucket, I used a fuzzy match between the Wikipedia and kworb.net list. I then scrapped [song-level artist streaming data](https://kworb.net/spotify/artist/3TVXtAsR1Inumwj472S9r4.html) from kworb.net, which tracks song features. The ‘node’ dataset for the network chart was created by pivoting this data to obtain “collaboration counts” between artists. 

