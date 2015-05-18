# Introduction #

First check in of library.


# Details #

This first revision has:

**Application module**

  * S4AppUtils: Commonly used iPhone application utilities.
  * S4FileUtils: Commonly used iPhone file utilities; finds most-used directories and has an NSKeyArchiver utility for storing objects persistently.

**GeoLocation module**

  * S4CoreLocationManager: for now, just a singleton class that handles CoreLocation subtleties for you.

**Network module**

  * S4HttpConnection: handles the small details of making HTTP connections for you
  * S4NetUtilities: creates NSURLRequests, properly escapes URL NSStrings, plus more