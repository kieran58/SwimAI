# One time setup

Everything below is done from your own laptop, in a browser and a terminal. None of
it needs a Mac. Once this is done, every future build happens on GitHub's own Mac
when you push code.

## 1. Join the Apple Developer Program

Go to developer.apple.com, sign in with your Apple ID, and enrol. This costs ninety
nine dollars a year and Apple checks your identity, which can take a day or two.
Do this first, since nothing else can start until it clears.

## 2. Note your Team ID

Once enrolled, go to developer.apple.com/account. Your Team ID is a ten character
code shown on that page. Save it somewhere; you will need it below as `TEAM_ID`.

## 3. Make a certificate signing request, no Mac needed

A Mac would normally do this through an app called Keychain Access, but plain
`openssl` does the same job. In a terminal:

```
openssl genrsa -out ios_distribution.key 2048
openssl req -new -key ios_distribution.key -out ios_distribution.csr -subj "/emailAddress=you@example.com, CN=Kieran, C=GB"
```

Change the email and name to your own. This leaves you with two files:
`ios_distribution.key` (keep this, never share it) and `ios_distribution.csr`
(you upload this next).

## 4. Create a distribution certificate

In the Apple Developer site, go to Certificates, Identifiers and Profiles,
Certificates, and click the plus button. Choose "Apple Distribution", upload
`ios_distribution.csr`, and download the resulting `.cer` file.

## 5. Turn the certificate into a .p12 file

```
openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM
openssl pkcs12 -export -out certificate.p12 -inkey ios_distribution.key -in distribution.pem -password pass:CHOOSE_A_PASSWORD
```

Pick your own password in place of `CHOOSE_A_PASSWORD` and remember it; this becomes
the `P12_PASSWORD` secret below.

## 6. Register an App ID

Still in Certificates, Identifiers and Profiles, go to Identifiers, click the plus
button, choose App IDs, then App. Set the bundle ID to something like
`com.kieran.swimai` (this becomes `BUNDLE_ID` below) and tick HealthKit under
Capabilities.

## 7. Create a provisioning profile

Go to Profiles, click the plus button, choose "App Store" under Distribution,
pick the App ID from step six, then the certificate from step four. Name the
profile (for instance "Swim AI App Store") and download it. This name becomes
`PROVISIONING_PROFILE_SPECIFIER` below.

## 8. Create an App Store Connect API key

Go to appstoreconnect.apple.com, Users and Access, Integrations, App Store
Connect API. Click the plus button, give it a name, and set access to App
Manager. Download the `.p8` file straight away; Apple only lets you download it
once. Note the Key ID and Issuer ID shown on that page.

## 9. Turn your files into base64 text, ready for GitHub

```
base64 -i certificate.p12 | tr -d '\n' > certificate_base64.txt
base64 -i profile.mobileprovision | tr -d '\n' > profile_base64.txt
base64 -i AuthKey_XXXXXXXXXX.p8 | tr -d '\n' > authkey_base64.txt
```

(On Windows, use `certutil -encode certificate.p12 certificate_base64.txt` instead,
then open the file and strip the first and last lines, which are headers certutil
adds.)

## 10. Add GitHub secrets

Push this project to a new GitHub repository. Then, in that repository, go to
Settings, Secrets and variables, Actions, and add each of these as a secret:

| Secret name | Value |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | contents of `certificate_base64.txt` |
| `P12_PASSWORD` | the password you chose in step five |
| `BUILD_PROVISION_PROFILE_BASE64` | contents of `profile_base64.txt` |
| `KEYCHAIN_PASSWORD` | any password, made up just for this; the workflow uses it to lock a throwaway keychain on the runner |
| `TEAM_ID` | your Team ID from step two |
| `BUNDLE_ID` | the bundle ID from step six, e.g. `com.kieran.swimai` |
| `PROVISIONING_PROFILE_SPECIFIER` | the profile name from step seven |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from step eight |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step eight |
| `APP_STORE_CONNECT_API_KEY_BASE64` | contents of `authkey_base64.txt` |

## 11. Create the app record in App Store Connect

This part is the same as the original App Store guide, and is done entirely in a
browser. In App Store Connect, My Apps, click the plus button, New App, and fill
in the bundle ID from step six, name, and language.

## 12. Run the build

In your GitHub repository, go to the Actions tab, choose "Build and upload Swim
AI", and click "Run workflow". This checks out your code on a Mac that GitHub
owns, signs the app with the certificate and profile from your secrets, and sends
the finished build to App Store Connect. It normally takes about ten minutes.

If it fails, open the failed step and read the log. Paste that log to me and I
will work out the fix from the text alone; I do not need a Mac to read an error
message.

## 13. Finish in App Store Connect

Once the build shows up under your app in App Store Connect (this can take a few
minutes after the workflow finishes), go back to the earlier App Store guide from
step five onwards: screenshots, description, age rating, and submit for review.
All of that is done in a browser, same as step eleven.

## A note on cost

GitHub gives you free build minutes each month; Mac builds use up your quota
faster than other kinds. Past that quota, a Mac build minute costs a small
fraction of a dollar, so an occasional build to ship an update costs pennies,
not pounds.
