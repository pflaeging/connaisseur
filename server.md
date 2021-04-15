Flask - While lightweight and easy to use, Flask’s built-in server is not suitable for production https://flask.palletsprojects.com/en/1.1.x/deploying
Flask - When running publicly rather than in development, you should not use the built-in development server (flask run). The development server is provided by Werkzeug for convenience, but is not designed to be particularly efficient, stable, or secure.   https://flask.palletsprojects.com/en/1.1.x/tutorial/deploy/
Some list at https://flask.palletsprojects.com/en/1.1.x/deploying/wsgi-standalone/

bjoern - python2

gunicorn - high error/timeout rate at 1 worker per pod, simple, good according to https://medium.com/django-deployment/which-wsgi-server-should-i-use-a70548da6a83, errors even at 4 workers, 1 of 5 invocations of integration test failed on local kind cluster
"Error from server (InternalError): error when creating "connaisseur/tests/integration/valid_container_with_unsigned_init_container_image.yml": Internal error occurred: failed calling webhook "connaisseur-svc.connaisseur.svc": Post "https://connaisseur-svc.connaisseur.svc:443/mutate?timeout=30s": net/http: request canceled (Client.Timeout exceeded while awaiting headers)"
!!! also as set up currently, gunicorn needs writable /tmp dir, which can affect the k8s NODE -> either fix or no solution

uwsgi - works well 2 processes; really bad according to https://www.appdynamics.com/blog/engineering/a-performance-analysis-of-python-wsgi-servers-part-2/, 
error at 2 processes (felt like fewer though):
Allowed an unsigned image via init container or failed due to an unexpected error handling init containers. Output:
Error from server (InternalError): error when creating "connaisseur/tests/integration/valid_container_with_unsigned_init_container_image.yml": Internal error occurred: failed calling webhook "connaisseur-svc.connaisseur.svc": Post "https://connaisseur-svc.connaisseur.svc:443/mutate?timeout=30s": net/http: request canceled (Client.Timeout exceeded while awaiting headers)

cheroot (default numthreads=10)

## errors

Flask tests 11/50 (failed due to timeout/tests run)
gunicorn with 4 workers (6/50)
gunicorn with 10 workers (0/50)
uwgsi with 2p and 1t  (6/50)
cheroot (3 or 4/50) 3 timeouts and
Error from server: error when creating "connaisseur/tests/integration/valid_container_with_unsigned_init_container_image.yml": admission webhook "connaisseur-svc.connaisseur.svc" denied the request: unknown error. please check the logs.



50 iterations, order per iteration random; timeout + unknown
cheroot 2
uwsgi 3
gunicorn 2

## resources

### flask

kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)   
connaisseur-deployment-79db9b9f58-9vnrb   17m          26Mi            
connaisseur-deployment-79db9b9f58-b6fcw   13m          25Mi            
connaisseur-deployment-79db9b9f58-h44gk   13m          25Mi

### gunicorn (4 workers)

kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)   
connaisseur-deployment-6cd449d678-f6xsf   18m          114Mi           
connaisseur-deployment-6cd449d678-ml54j   23m          118Mi           
connaisseur-deployment-6cd449d678-qkpqs   13m          119Mi 

### gunicorn (10 workers)
kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)   
connaisseur-deployment-694795df49-62sm6   15m          247Mi           
connaisseur-deployment-694795df49-7q7gm   15m          246Mi           
connaisseur-deployment-694795df49-8l5lk   41m          246Mi         

### uwsgi 
kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)   
connaisseur-deployment-6cd449d678-4kh82   16m          56Mi            
connaisseur-deployment-6cd449d678-wgqs8   14m          57Mi            
connaisseur-deployment-6cd449d678-xhv97   14m          57Mi

### cheroot
kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)
connaisseur-deployment-6cd449d678-d79fj   23m          31Mi
connaisseur-deployment-6cd449d678-hw4b5   25m          35Mi
connaisseur-deployment-6cd449d678-rxpqp   96m          33Mi