# bookstore-api

Here there is an bookstore api app that is written by using pyhton. In this app we can reach book list. We can search it for a specific one to find. 
Also we can edit them and of course delete them.

As DevOps Engineer we are trying to deploy this api by using Docker in a container. Because of that we need to create a Dockerfile in order to create an image. 
Then from this image we will create our container that contains our api app and it's all dependencies.

We can also create our infrastructure with Terraform. As you know Terraform is an IaC (Infrastructure as Code) tool. Here first of all we create our environment and 
infrastructure with Terraform. But this is not required, it is optional. Nevertheless I will create a terraform file to create my environment. 

After creating my environment, I will write Dockerfile to create my image contains api app. After that I create a container that consist of api app and it's all 
dependencies.

At the end by using containarization we can deploy our api publicly.
