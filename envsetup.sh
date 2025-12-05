steps:
# Step 1: Checkout code
- name: Checkout Code
  uses: actions/checkout@v4

# Step 2: Set up Java 17
- name: Set up Java 17
  uses: actions/setup-java@v3
  with:
    java-version: '17'

# Step 3: Set up Maven
- name: Set up Maven
  uses: actions/setup-java@v3
  with:
    distribution: 'maven'

# Step 4: Build the project
- name: Build with Maven
  run: mvn clean package

# Step 5: Upload the built JAR as an artifact
- name: Upload Artifact
  uses: actions/upload-artifact@v4
  with:
    name: built-jar
    path: target/simple-parcel-service-app-1.0-SNAPSHOT.jar

# Step 6: Run the Spring Boot application
- name: Run Application
  run: |
    nohup mvn spring-boot:run &
    sleep 15 # Allow time for the app to fully start

# Step 7: Validate App is Running
- name: Validate App is Running
  run: |
    echo "Waiting for the app to start..."
    sleep 15  # Allow some time for the Spring Boot app to fully start
    echo "Checking if the app is running..."
    RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null http://localhost:8080)
    if [ "$RESPONSE" -eq 200 ]; then
      echo "The app is running successfully!"
    else
      echo "The app failed to start. HTTP response code: $RESPONSE"
      exit 1
    fi

# Step 8: Wait for 5 minutes
- name: Wait for 5 minutes
  run: |
    echo "App has been running for 5 minutes. Waiting..."
    sleep 300  # Wait for 5 minutes (300 seconds)

# Step 9: Gracefully Stop Spring Boot App
- name: Gracefully Stop Spring Boot App
  run: |
    echo "Stopping the app gracefully..."
    mvn spring-boot:stop
