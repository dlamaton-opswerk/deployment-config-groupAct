# Use an official, lightweight Python runtime as a parent image
ROM python:3.12-slim-bookworm

# Set environment variables to optimize Python behavior
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Copy only requirements first to leverage Docker cache layers
COPY requirements.txt .

# Install the application dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Inform Docker that the container listens on port 5000 at runtime
EXPOSE 5000

# Use Gunicorn as the production WSGI server instead of the Flask dev server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
