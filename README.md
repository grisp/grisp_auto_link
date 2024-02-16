# grisp_auto_link

## What is this?

A grisp application that tries to connect to GRiSP.io, and link the device.

This app has been thought to be serviced to the user through the GRiSP.io device web view.

## Get the package from GRiSP.io

Login on [grisp.io](https://grisp.io) and navigate to your Grisp Manager web view.

1. Click on `Link Device` button
2. Follow instrucitons to download a ready made application.
   1. Click `Download Application`
   2. GRiSP Manager will fill the `config/sys.config` file of this project with a valid token and offer the deployed app to the user in a zip file.
   3. Extract the zip content onto an SD card.




Finally, insert the SD card and connect the board to the internet via an ethernet cable. You should see your device appear on the Grisp Manager web page.

## Manual deployment

Alternatively, you can clone this repo and copy the `device_linking_token` from the web page directly inside `config/sys.config`.

You might want to setup wpa_supplicant settings for you WiFi since you are here. You do not need it if you plan to use an ethernet cable.

Then you can deploy the app on the grisp board as it is done for any standard GRiSP application.
