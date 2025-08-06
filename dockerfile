# Step 1: Use an official Python base image
FROM python:3.10-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy requirements file and install packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Step 4: Copy all application files to the container
COPY . .

# Step 5: Set the default command to run the app
CMD ["python", "app.py"]

EXPOSE 5000
