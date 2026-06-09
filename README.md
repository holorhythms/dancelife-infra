## Manual actions after applying Terraform configuration

### Add DNS CNAME and TXT records to domain host
* Add CNAME records for each of the environments being used for their unique subdomain
  * i.e. {"api-dev", "dancelife-app-service-dev.azurewebsites.net "}
* Add TXT records for each subdomain to supply the domain verification id
  * i.e. {"asuid.api-dev", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

### Get App Service staging slot publish profile and update/create Github secret
* Go to the App Service --> Deployment --> Deployment Slots --> staging, then download the publish profile
* Go to the Github repository's settings and add the publish profile as a secret with a [PUBLISH_PROFILE_SECRET_NAME], to be used in the Github actions workflow
  * If the secret already exists, update with the new publish profile value

### Modify generated Github actions workflow files
* This is only necessary if the corresponding resources are newly created (i.e. via a new environment stack being created)
* For `dancelife-web-portal`:
  * At the `Build & Deploy` step, change `output_location` to "build"
* For `dancelife-adonisjs`:
  * Add the following block after the `on` block:
    ```
    # Default env to pass test run during deployment
    env:
    TZ: UTC
    PORT: 80
    HOST: localhost
    LOG_LEVEL: info
    LOG_LEVEL_CLI: info
    APP_KEY: testtesttesttest
    HOST_ENV: dev
    NODE_ENV: development
    SESSION_DRIVER: cookie
    DB_HOST: 127.0.0.1
    DB_PORT: 5432
    DB_USER: root
    DB_PASSWORD: root
    DB_DATABASE: app
    AZURE_STORAGE_ACCOUNT_NAME: teststorageaccount
    AZURE_STORAGE_CONTAINER_ENVIRONMENT_PREFIX: testenv
    GOOGLE_MAPS_API_KEY: testkey
    WORKOS_CLIENT_ID: testworkosclientid
    WORKOS_API_KEY: testworkosapikey
    WORKOS_COOKIE_PASSWORD: testworkoscookiepassword32pluscharslong

    ```
  * Add the following block after the `npm install, build, and test` block
    ```
    - name: Run npm install in build directory
      run: |
        cd build
        npm install
        cd ..
    ```
  * For the 'Deploy to Azure Web App' block, change the `package` to './build'
  * For the `publish-profile`, reference the secret name [PUBLISH_PROFILE_SECRET_NAME] from above 