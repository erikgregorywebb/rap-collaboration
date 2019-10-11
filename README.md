# A Brief Study of Collaboration in Rap Music

I love music, especially rap music. In the world of rap, almost nothing beats hearing two or more of your favorite artists team up on a song. A well-placed guest verse can launch a career! Looking to systematically analyze collaboration in rap, I compiled a dataset of 500+ hip-hop artists and x+ tracks to understand which of my favorite rappers enjoy working with each other.

### Visualization
The visual was created using Flourish, a data visualization and storytelling platform. Click here for a live version.

### Methodology
I first created a list of rappers and rap groups from Wikipedia. I then scrapped kworb.net, a music data site, for a list of the top 10,000 artists on Spotify. In order to determine which of the 10K artists fell into the rap bucket, I used a fuzzy match between the Wikipedia and kworb.net lists. I then scrapped song-level artist streaming data from kworb.net, which lists any artists featured on a song. The “node” dataset for the network chart was created by pivoting this data to obtain “collaboration counts” between artists.
