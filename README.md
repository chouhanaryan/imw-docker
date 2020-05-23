# About

This repository contains files that are required to build a Docker image of the [Inventory Management website](https://github.com/djunicode/inventory-management-web) built by [Unicode](https://github.com/djunicode).

The aim was to make to make it as easy as possible to deploy and have it scale as per our requirements.

Containerizing the application was the obvious choice for implementing this.

# Image

The image is publicly available on [Docker Hub](https://hub.docker.com/r/chouhanaryan/imw).

# Deployment

Currently, we deploy our website using Amazon Web Services' Elastic Beanstalk.

Only a single file is required to deploy the image.

#### Dockerrun.aws.json

```
{
	"AWSEBDockerrunVersion": "1",
	"Image": {
		"Name": "chouhanaryan/imw:stable",
		"Update": "true"
	},
	"Ports": [
		{
			"ContainerPort": "8000"
		}
	],
	"Logging": "/var/log/server"
}
```

The file is uploaded as a source code file while creating a new Environment.

Note:
1. The name of the image is with respect to its name on Docker Hub. Other ways of using images from different Container Registeries are well-documented [here](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/single-container-docker-configuration.html).
2. The port points to the port that was exposed by the image [here](https://github.com/chouhanaryan/imw-docker/blob/master/Dockerfile#L23).

# Extra Notes

This section serves to document what I have learnt in implementing this and the journey I undertook to arrive at the current solution.

At the outset, it was clear that using `python manage.py runserver` was not going to cut it for a production build. The options we had were:
1. Gunicorn
2. uWSGI
3. Apache and mod_wsgi

Gunicorn was the cleanest of them all and the easiest to work with, so that is was I chose.

Unfortunately, Gunicorn cannot be used to serve static and media files.

Since our application's frontend is based on React, we needed a clean, hassle-free and robust way to do this.

I immediately chose Nginx because of its ease of use and insane customization capabilites. Keep in mind, my secondary aim (apart from solving the problem at hand), is to learn as much as possible. Choosing this route served that purpose very well.

Nginx does two things at any given instant. It captures each request and if the request attempts to access a static resource, it routes it to the appropriate directory, while every other request is forwarded to Gunicorn which the app takes care of.

The solution was thus this. I had to have two containers - one, hosting the Django app with Gunicorn acting as the WSGI server and two, an Nginx server to handle the requests.

Since I am still learning Docker, I chose the most native and compatible solution to implement this - Docker Compose.

I created the appropriate `docker-compose.yml` and `Dockerfile`s (plural because this is a two-container application).

The code for this is available [here](https://github.com/chouhanaryan/imw-docker-compose).

The next step was deployment - making the actual push to Beanstalk. As I opened the docs, I soon realized that the syntax for the `Dockerrun.aws.json` file for a multi-container application, differed very, very, very much from the file for deploying a single-container application.

It did seem simple at first - I only had to translate my `docker-compose.yml` to the `Dockerrun.aws.json` file making sure all volumes, ports and resources were appropritately mapped.

However, it didn't take long for me to give up.

I needed another solution, and so I went about looking for ways to somehow combine the two containers I have. It would be fantastic if I could somehow have Nginx run on the same container as I did my Django app.

Much of this was next to futile and although it might be possible, it didn't seem like a path I wanted to go down.

I took a step back and analyzed the problem at hand. The truth is that the only real issue I had had to do with serving static files.

I decided to do a deep dive into how one might go about serving static files in a production environment and I arrived at two choices - using a CDN or using an internal tool such as WhiteNoise.

I ended up choosing WhiteNoise since it fit our needs best.

As I dove further into its implementation, I realized I needed to refactor the way our static files were organized as well.

At the end of the process - it all worked out. 

I got rid of Nginx, kept Gunicorn intact, used WhiteNoise to serve static files, built a new Docker image and made the codebase a little bit cleaner along the way.

# Future Steps

The current setup doesn't take incorporate a production-grade database such as PostgreSQL or MySQL. Making a separate container for the database isn't usually a good option. Ideally, we can spin up an RDS instance alongside the container and directly connect the two on AWS.

That is my next goal.
