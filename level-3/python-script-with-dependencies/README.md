# Caching improvements
Looking at `bad-caching.Dockerfile` compared to `Dockerfile`
we see a difference in
```dockerfile
# copy files into container
COPY . .

# install requirements
RUN pip install -r requirements.txt
```
vs
```dockerfile
# copy requirements file
COPY requirements.txt .

# install requirements
RUN pip install -r requirements.txt

# add script
COPY script.py .
```
This is bad due to the fact that in the former version we will have with a probability of 100% 
changes in files, that's the reason we build the container again, right?  
So the statement
```dockerfile
COPY . .
```
will **never** use a cached version of it and the following ones will be invalid,
so upon every execution of `docker build` we will install our dependencies.
In the latter version though we will only install the dependencies once the content of `requirements.txt` has changed.
This improves the build time drastically, especially with heavy dependencies such as `numpy`.