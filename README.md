# Assignment

Case Study - A/B Test Infrastructure

## Environment
Docker to build images
Docker Desktop Kubernetes for Windows as deployment cluster
Istio as ingress controller

## Solution


As a solution, I have created , 
* dockerfile to convert java binary into a docker image - binary and docker file present in folder java-app
* dockerfile to convert go binary into a docker image - binary and docker file present in folder go-app
* kubernetes script deployment.yml to deploy the java binary image and go binary image into local Kubernetes Cluster and expose using a service.
* ingress.yml to define the weighted ingress rules for java and go binary.
* test-image to test the component from other pod inside the cluster as a service via HTTP - docker file present in folder test-image
* sample-test.yml to deploy test image.
* istio-ingress-1.1.2.yaml to install istio ingress controller, as by default ingress controllers are not installed on kubernetes.


### Steps Executed to prepare the solution

1) Download the golang-webserver and java-webserver.jar from the given link in the assignment in folder go-app and java-app respectively. 
2) Created a <b> dockerfile </b> to convert java-webserver.jar into a docker image. 
3) execute below command to build java binary docker image from the location of docker file, current directory `solution`
		`docker build java-app/ -t java-webserver` 
4) Created a <b> dockerfile </b> to convert golang-webserver into a docker image.
4) execute below command to build java go docker image from the location of docker file, current directory `solution`
		`docker build go-app/ -t java-webserver`		
		
5) Created <b> deployment.yml </b> for the deployment of the created docker images i.e. java-webserver and golang-webserver
* The yml file contains two parts, 
* Kind : Deployment set to deploy the images as pods with 
	* java-webserver image with label as version: v1
	* golang-webserver image with label as version: v2
	* labels will be used while defining ingress rule distinguish the traffic redirection and will allow weighted approach
	* replication factor as 2 for go app and 1 for java app, as go app needs to handle 70% of the traffic
* Kind : service with name as hotelservice to expose the pods on port 8080.

6) Execute the below command for deployment of Deployment and Service,
         `kubectl apply -f deployment.yml` 
Response should be 
deployment.apps/java-app created
deployment.apps/go-app created
service/hotelservice created

7) Execute below command to get the list of deployed pods, it can take some time before pods are up and running depending on readiness probe.
          `kubectl get pods`
Output should be 
NAME                          READY   STATUS    RESTARTS   AGE
go-app-5b687899fd-clt5z       1/1     Running   0          113s
go-app-5b687899fd-lshqk       1/1     Running   0          113s
java-app-57cd78855b-hwqqq     1/1     Running   0          113s

8) To test the application from local browser, execute the below command,and keep the console open
          `kubectl port-forward <pod-name> 8080:8080` example in this case:- kubectl port-forward sample-app-789f8c5bb7-7c6dw 8080:8080
9) Now trigger the url again from browser, http://localhost:8080/ it should work.
10) Also check the status of the service, with below command, service should be succesfully deployed. `kubectl get services` Service is exposed with name as "hotelservice".
        
11)To test the service from another pod in the same cluster, create a test image which supports curl command.
           `docker build -t test-image test-image/`
           
12)Deploy the test-image using below command, 
           `kubectl apply -f sample-test.yml` 
           
13)Test test-image pod should be up and running, `kubectl get pods`

14)To test, we need to ssh into test-image pod, use below command,
         `kubectl exec -it test-image sh`
         
15)Execute the curl command from within the test-image pod, we should get the successful response. This pod could be used for testing the traffic redirection based on scripts.
         `curl http://hotelservice:8080/health`
		 
16)To redirect the traffic in desired way, we need to create the ingress rules. Since, by default Kubernetes cluster is not installed with Ingress Contoller, I am selecting istio as Ingress controller in this scenario.

17To install istio, execute the below command,
		  `kubectl apply -f istio-ingress-1.1.2.yaml`
		  
18) Verify if istio is successfully installed, execute below command from test-image pod, again after ssh as mentioned in 15.
		  `curl http://istio-ingressgateway.istio-system:15020/healthz/ready`

19) Deploy Istio ingress rules, using below command
		  `kubectl apply -f ingress.yaml`
* Destination Rule, will create subsets v1 and v2 based on labels version:v1 and version:v2
* Virtual Service, will redirect weighted approach based on subset v1 and subset v2 with weighted approach as 30% and 70% for all urls
* Also, Virtual Service, will redirect all the traffic matching url / towards, /hotels, to keep it short i have redirect to version v2 in this scenario.

20) To verify, execute below command from test-image pod, again after ssh as mentioned in 15. It should provide weighted distribution.
	`for i in 1 2 3 4 5; do curl http://hotelservice:8080/health; done`
Although, istio installation works fine on docker desktop, still ingress rules might not be successfully executed due to restricted network policies and firewalls. This approach should work on any cloud provider.

            


		


