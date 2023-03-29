# Extra: Containers
## Assignment description
This task has two main objectives, the first one is to familiarize yourself with containerization (using Docker) and the running of containerized, interconnected services. After being familiar with containers, the second task is to host the same system using Kubernetes for orchestrating the containers. This adds scalability by using deployed services.

It is strongly recommended to do this assignment on your main Linux (i.e. not on a virtual machine) because running Docker and Kubernetes on a VM results in nested virtualization, which VirtualBox has limited support for. If you want to do the assignment on a virtual machine, VMWare Workstation Player is a free software that allows running Docker inside your VM.

## 1. Preparation
You can download the files needed for the assignment at: https://version.aalto.fi/gitlab/illahig1/containers.git

Then, install Docker and create a user to Docker Hub. This is necessary because you will be building and pushing images there.

### 1.1 Show your Docker Hub for this assignment’s containers.
https://hub.docker.com/u/hollowman6

### 1.2 How can you use one Docker repository to hold multiple containers?
We can use tags to differentiate multiple containers in a single Docker repository. Each container image can be tagged with a unique identifier, and when you push the image to Docker Hub, you can specify the tag name to distinguish it from other containers in the same repository. For example, you can have a repository called "myrepo" and push two different images with tags "myimage1" and "myimage2" respectively, using the following commands:

```bash
docker build -t myrepo:myimage1 .
docker push myrepo:myimage1

docker build -t myrepo:myimage2 .
docker push myrepo:myimage2
```
This will allow you to manage multiple container images in a single Docker repository.

## 2. Docker
You will host three services on different Docker containers: a react webpage, which is the frontend of the website; a spring web application, which contacts a python application and returns the results in json format; and a python application containing the website logic. Due to this architecture, you will need to build the website in reverse order, as the spring application will need to know the IP address of the Python application, and the webpage will need to know the Spring application’s IP. To test out the Docker installation however, you will first build the frontend of the website. Then build the other services and change the webpage to point to the right address.

1. Go to sa-frontend folder in the files. Before you can build your first Docker image, you need to build the webpage. To do this, you need to install npm. After installing npm, run “npm install” to download the required scripts, and run “npm run build” to build the webpage. After building the webpage, build a Docker image by using the Dockerfile. Push the created image to your Docker hub. Finally, run the created image in a Docker container, and configure it so that port 3000 on localhost points to port 3000 on the container.

Hint: use commands “docker build” and “docker push”

2. Check that you can access the website frontpage on http://localhost:3000 using a web browser. The button doesn’t work yet, as the software logic isn’t running.
3. Go to sa-logic folder, and build the Docker image using the Docker file. Push the image to your hub, and run the application, listening on port 5050 of the host and 5000 of the container.
4. To be able to build the webapp-image, you will need to install jdk and maven. After installing them, go to sa-webapp folder and run the command mvn install. It will create a new directory called target. After this, find the IP address of the running logic-container, and edit the Dockerfile, so that the IP points to that service. You also need to edit the ADD and CMD -lines so that they point to the correct .jar file in target directory. Build the docker image, push it to your hub, and run the application, listening on port 8080 of both host and the container.
5. Now you need to change the sa-frontend/src/App.js -file to fetch data from the webapp container. Edit the analyzeSentence() -function. Before building the Docker image, you will need to build the webpage again. Afterwards, build the Docker image, push it to your hub and run the application.
6. The website should now work on your browser. Go to http://localhost:3000 and type a phrase to see the sentiment you get. If the website doesn’t work, try clearing your browser cache of any previous versions it may have stored.

### 2.1 List the commands you used for building, pushing and running the containers
```bash
cd sa-frontend
npm install
npm run build
docker build -t hollowman6/sa-frontend .
docker push hollowman6/sa-frontend
docker run -p 3000:80 --name sa-frontend hollowman6/sa-frontend
cd ../sa-logic
docker build -t hollowman6/sa-logic .
docker push hollowman6/sa-logic
docker run -p 5050:5000 --name sa-logic hollowman6/sa-logic
cd ../sa-webapp
mvn install
docker build -t hollowman6/sa-webapp .
docker push hollowman6/sa-webapp
docker run -p 8080:8080 --name sa-webapp hollowman6/sa-webapp
docker network create sa-network
docker network connect sa-network sa-logic
docker network connect sa-network sa-webapp
```
### 2.2 Show the IP of one of the running containers
```bash
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}; {{end}}' sa-logic
172.17.0.2; 172.18.0.2;
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}; {{end}}' sa-webapp
172.17.0.3; 172.18.0.3;
```
### 2.3 Demonstrate that the website is running and functional


### 2.4 Explain your changes to the Dockerfiles


## 3. Kubernetes
Now you will add scalability to your service by using load balancers and deployments. In Kubernetes, deployments can be used to create a replica-set of a service, allowing for scaling of the service for your needs. A load balancer will forward your request to one of the replicas, which will deliver the service. The resulting service topology will look like this:

1. This section requires you to install Minikube for running a Kubernetes cluster, as well as kubectl, a client tool for accessing the cluster. Install them and start Minikube.
2. Go to resource-manifest directory, and create a Kubernetes pod using sa-frontend-pod.yaml. Edit the yaml-file to use the frontend container image from your Docker hub. Set port-forwarding so that you can access the pod’s port 80 on localhost port 88. Make sure you can see the webpage.
3. To add scalability to your website, create another frontend pod from sa-frontend-pod2.yaml. Use the container image from your hub. Check that the new pod is running. This is not the best way to provide scalability, but it will be improved in further steps.
4. You will now add a load balancer service to direct traffic to one of the front pages. The load balancer recognizes the pods by the label “app: sa-frontend”. Make sure both pods have that label. Then run the service using service-sa-frontend-lb.yaml. Check that the service is running. Don’t worry if the IP stays in pending; it is because you are using minikube and not a cloud service. You need to locally solve this issue, so that you can access it by using the web browser.
5. At this point the load balancer is recognizing the pods based on a label. That fulfills the requirements for a scaled application. Now you need to run two replicas of the frontend -pod using a deployment. You can do it by using sa-frontend-deployment.yaml. Once again, you need to edit the file to use your own container image. After you have the deployment running, remove the two pods created in the previous steps using kubectl delete.
6. Now it’s time to deploy the other services. Start by deploying logic. Edit the yaml file to use your own container. Remember to apply the logic service as well as the deployment. After this, verify that the service and pods are  running.
7. Finally, you need to deploy the webapp service and load balancer. Note that the yaml-file has defined the environment variable pointing to the logic service URL, so you don’t need to change that. Change the file to use your container image, though. After the edits, start the deployment and the load balancer.
8. Note that you must change the frontend App.js to point to the right address again. Use the IP of the webapp load balancer. You can get it by using “minikube service list”. After making the changes, use npm to build the webpage, build the docker image, and upload it to Docker Hub. Then reapply the deployment. The website should now be accessible and working through the frontend load balancer service.

## 3.1 List the commands you used for running the services, pods and deployments
```bash
minikube start
cd resource-manifests
kubectl apply -f sa-frontend-pod.yaml
sudo -E minikube kubectl -- port-forward pod/sa-frontend 88:80
kubectl apply -f sa-frontend-pod2.yaml
kubectl apply -f service-sa-frontend-lb.yaml
kubectl get svc
kubectl apply -f sa-frontend-deployment.yaml
kubectl delete po sa-frontend sa-frontend2
kubectl apply -f sa-logic-deployment.yaml
kubectl apply -f sa-web-app-deployment.yaml
kubectl apply -f service-sa-logic.yaml
kubectl apply -f service-sa-web-app-lb.yaml
```

## 3.2 Demonstrate the website is running by connecting to the frontend load balancer. How does this differ from connecting to one of the pods?

```bash
minikube tunnel
```

This differs from connecting to one of the pods directly because the load balancer distributes traffic across multiple pods, while connecting to a single pod only serves traffic to that specific pod.

## 3.3 Explain the contents of sa-frontend-deployment.yaml, including what changes you made
The sa-frontend-deployment.yaml file specifies a Kubernetes deployment for the frontend service. It creates a set of frontend pods and manages their lifecycle, ensuring that the desired number of replicas are always running.

1. apiVersion: apps/v1: Specifies the API version of Kubernetes resources that the configuration applies to. In this case, it's apps/v1, which is the stable API version for Deployments.

2. kind: Deployment: Defines the type of Kubernetes resource being created, which is a Deployment in this case.

3. metadata:: Contains metadata about the Deployment, such as its name and labels.
  * name: sa-frontend: The name of the Deployment, which is sa-frontend.

4. spec:: Specifies the desired state of the Deployment.
  * replicas: 2: The desired number of replica pods to be maintained by the Deployment. Here, 2 replicas are specified.

  * minReadySeconds: 15: The minimum number of seconds a pod should be ready without any of its containers crashing to be considered available. In this case, it's 15 seconds.

  * selector:: Determines which pods are managed by the Deployment based on their labels.
    * matchLabels:: A set of key-value pairs that must match the labels of the pods.
    * app: sa-frontend: The key-value pair specifying that the pods with the label app=sa-frontend are managed by this Deployment.
  
  * strategy:: The update strategy for the Deployment when new changes are applied.
    * type: RollingUpdate: Specifies that a rolling update strategy should be used to update the pods.
    * rollingUpdate:: The parameters for the rolling update strategy.
      * maxUnavailable: 1: The maximum number of pods that can be unavailable during the update process. In this case, it's 1 pod.
      * maxSurge: 1: The maximum number of extra pods that can be created during the update process. In this case, it's 1 pod.
  * template:: The template for creating new pods, which is instantiated when scaling or updating the Deployment.
    * metadata:: Contains metadata about the pod template.
    * labels:: The labels to be applied to the pods created from this template.
      * app: sa-frontend: The key-value pair specifying the label app=sa-frontend.
  * spec:: Specifies the desired state of the pod, including the containers running in it.
    * containers:: A list of containers to be run within the pod.
      * image: jinjia/sa-frontend:v1: The container image to be used, which is jinjia/sa-frontend:v1.
      * imagePullPolicy: Always: Specifies when to pull the container image. In this case, it's set to Always, which means the image will be pulled every time the pod starts.
      * name: sa-frontend: The name of the container.
      * ports:: A list of ports to expose from the container.
      * containerPort: 80: The port number to be exposed from the container, which is port 80.

## 3.4 How can you scale a deployment after it has been deployed?
```bash
kubectl scale deploy sa-frontend --replicas=3
```

Autoscaling:
```yaml
apiVersion: autoscaling/v1
 kind: HorizontalPodAutoscaler
 metadata:
   name: api
 spec:
   scaleTargetRef:
     apiVersion: apps/v1
     kind: Deployment
     name: api
   minReplicas: 1
   maxReplicas: 5
   targetCPUUtilizationPercentage: 20
```

Scaling a deployment after it has been deployed involves increasing or decreasing the resources allocated to the deployment to meet changing demand or performance requirements. Here are a few ways to scale a deployment:

- Horizontal scaling: Horizontal scaling involves adding more instances of the same type to the deployment to handle increased demand. For example, if a web application is receiving more traffic than usual, adding more servers to handle the traffic can help distribute the load.
- Vertical scaling: Vertical scaling involves increasing the resources allocated to a single instance of the deployment. For example, upgrading the CPU, memory, or disk capacity of a server can help improve performance.
- Auto-scaling: Auto-scaling is a technique that allows a deployment to automatically adjust its resources based on demand. For example, an auto-scaling group in Amazon Web Services (AWS) can automatically add or remove instances based on the CPU utilization or network traffic.
- Container orchestration platforms like Kubernetes can automatically scale deployments based on metrics like CPU and memory usage, as well as custom metrics.
- Load balancing involves distributing incoming network traffic across multiple instances of a deployment. This can help improve availability and performance, and it can also enable horizontal scaling by automatically adding or removing instances based on traffic patterns.

It's important to note that scaling a deployment can have costs associated with it, both in terms of infrastructure and operational complexity. Therefore, it's important to carefully consider the trade-offs between scaling and cost when making decisions about deployment architecture.
