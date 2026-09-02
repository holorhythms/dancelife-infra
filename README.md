## Manual actions after applying Terraform configuration

### Add DNS CNAME and TXT records to domain host
* Add CNAME records for App Service for each of the environments being used for their unique subdomain
  * i.e. {"api-dev", "dancelife-app-service-dev.azurewebsites.net "}
* Add TXT records for each App Service subdomain to supply the domain verification id
  * i.e. {"asuid.api-dev", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}
* If using Front Door, instead set the App Service subdomains to the Front Door endpoints and TXT records instead. Examples:
  * CNAME: {"api-dev", "dancelife-app-service-dev-hgacb8d0e5gnbyb2.z03.azurefd.net "}
  * TXT: {"_dnsauth.api-dev", "_3h4gzmrwv4o068mggc0i6i5z98vzb4l"}

### Get App Service staging slot publish profile and update/create Github secret
* Go to the App Service --> Deployment --> Deployment Slots --> staging, then download the publish profile
* Go to the Github repository's settings and add the publish profile as a secret with a [PUBLISH_PROFILE_SECRET_NAME], to be used in the Github actions workflow
  * If the secret already exists, update with the new publish profile value

### Modify generated Github actions workflow files
* This is only necessary if the corresponding resources are newly created (i.e. via a new environment stack being created)
* For `dancelife-web-portal`:
  * At the `Build & Deploy` step, change `output_location` to "build"
* For `dancelife-admin-dashboard`
  * At the `Build & Deploy` step, change `output_location` to "dist"
* For `dancelife-adonisjs`:
  * For each environment, based on deployment strategy, copy the appropriate workflow template from the sample_github_workflows folder
  * Replace the contents of the generated github actions workflow file for the given environment with the template file contents
  * Replace instances of the environment placeholder with the actual environment name

### Verify Webjobs runtime is enabled in App Service
  * Go to App Service --> Settings --> Configuration
  * Make sure the "Webjobs runtime" setting is checked
    * It should be checked automatically based on the Terraform configuration settings, but behavior can sometimes be inconsistent
