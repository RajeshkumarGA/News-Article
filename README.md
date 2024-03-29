# News-Article
A news article app which give users options to save articles and read it offline.

![Simulator Screen Recording - iPhone 14 Pro - 2022-12-20 at 11 08 40](https://user-images.githubusercontent.com/19324077/208592096-f7c822ac-29c5-4895-8b13-0a56ba185e92.gif)


**Requirements:  Minimum:**
* Use of Web API to fetch news details. API - https://moedemo-93e2e.firebaseapp.com/assignment/NewsApp/articles.json.
* Make sure to persist the data obtained from the above API, for the offline scenario.
* Home Screen -
    * List the Articles obtained with Image, Title, and Description(max 3 lines)
    * Implement Image Caching for the offline scenario.
    * Implement a feature to Sort articles based on old-to-new and new-to-old.
    * Search feature to filter the articles based on Publishers/Authors.
* Detail screen -
    * On clicking the article in home screen, load the article URL on this detail screen.
    * Implement offline storage for reading articles offline. User should select the articles which he/she wants to save offline.
* The app should support iOS 12 and above versions.  
  
  **Good To Have:**
* Implement a feature to periodically fetch news when the application is in the background and present this content when the user opens the application.
* Implement the Push Notification feature inside the app using any of the Providers.
* Visually interactive design to list details.
* Custom design, font, and icons to make the app more user friendly.
* Use your imagination and add features that would make things easier for end-users.



**Note**
* I have used iOS NSCache for caching images. iOS by default uses cache eviction policy for NSCache in low memory conditions, we don't have to take care of memory issues by ourselves. But this is temporary, though have used Core data for storing articles. You can test image caching by opening the application with network connection, kill it, again open the app with no internet connection. You can see images in the cells are preloaded from cache.

**Working Feature**
* Show articles on home screen.
* Save articles to persistent storage(Core Data) for offline read.
* Search articles by author.
* Sort articles by publishedDate.
* See article description(Online).

**Missing**
* Articles details(Web views) are not stored in storage.
