FROM python:3.9

WORKDIR /code
#This line copies the requirements.txt file from the local directory 
#(where the Dockerfile resides) to the /code directory inside the container.
COPY ./requirements.txt /code/requirements.txt

#--no-cache-dir flag ensures that no cache is stored during the installation, and the 
#--upgrade flag ensures that the latest versions of the dependencies are installed.
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app /code/app
#It uses the Uvicorn server to run the Python application. 
#The "app.main:app" argument points to the app object in the main.py
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
