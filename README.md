A cache invalidation and purging service that can talk to Amazon CloudFront and Akamai CCUAPI.  
<<<<<<< HEAD

It supports cache invalidation modules so it's possible to add support for other CDN and cache services.


Required Environment / Minimum Setup
----------------------------------------------

Minimum setup required to run the app. This should be checked by dev:setup

Using ruby 1.9.3.

You need to start sidekiq worker:

```
bundle install
bundle exec sidekiq -C config/sidekiq.yml -L log/sidekiq.log
```

Notable Deviations
----------------------------------------------

Document any case where this project deviates from the standard policies.
Not using git flow? What's the branching model.
Esoteric release schedule? Document it.


Accessing the Site
----------------------------------------------

Is it running WEBrick, pow, unicorn?
Do you need to use custom subdomains or hosts?


Configuration
----------------------------------------------

Who do I speak with to get the values for configuration files?
Who/where do I go to for dev/production database dumps?


Walkthrough / Smoke Test
----------------------------------------------

Describe a manual smoke test process to ensure that the env is running as it should be.

Note: it is handy to use s3cmd if you're making invalidation requests to cloudfront:

```
curl -d 'cache[cache_type]=CloudFront' http://localhost:3000/caches
s3cmd cfinvalinfo cf://DIST_ID | head -n 30
```


Testing
----------------------------------------------

How do you run the tests?


Staging Environment
----------------------------------------------

Where is it?
How do I access it?
Who do I speak with to get access?


Production Environment
----------------------------------------------

Where is it?
How do I access it?
Who do I speak with to get access?
Is there a CDN? How does it work?
Is there a particular release process?


Design
----------------------------------------------

Spot for designers to put any information they need.


Known Issues / Gotcha
----------------------------------------------



Extended Resources
----------------------------------------------

link to extended resources

=======
 
 It supports cache invalidation modules so it's possible to add support for other CDN and cache services.
+
+
+Required Environment / Minimum Setup
+----------------------------------------------
+
+Minimum setup required to run the app. This should be checked by dev:setup
+
+Using ruby 1.9.3.
+
+You need to start sidekiq worker:
+
+```
+bundle install
+bundle exec sidekiq -C config/sidekiq.yml -L log/sidekiq.log
+```
+
+Notable Deviations
+----------------------------------------------
+
+Document any case where this project deviates from the standard policies.
+Not using git flow? What's the branching model.
+Esoteric release schedule? Document it.
+
+
+Accessing the Site
+----------------------------------------------
+
+Is it running WEBrick, pow, unicorn?
+Do you need to use custom subdomains or hosts?
+
+
+Configuration
+----------------------------------------------
+
+Who do I speak with to get the values for configuration files?
+Who/where do I go to for dev/production database dumps?
+
+
+Walkthrough / Smoke Test
+----------------------------------------------
+
+Describe a manual smoke test process to ensure that the env is running as it should be.
+
+Note: it is handy to use s3cmd if you're making invalidation requests to cloudfront:
+
+```
+curl -d 'cache[cache_type]=CloudFront' http://localhost:3000/caches
+s3cmd cfinvalinfo cf://DIST_ID | head -n 30
+```
+
+
+Testing
+----------------------------------------------
+
+How do you run the tests?
+
+
+Staging Environment
+----------------------------------------------
+
+Where is it?
+How do I access it?
+Who do I speak with to get access?
+
+
+Production Environment
+----------------------------------------------
+
+Where is it?
+How do I access it?
+Who do I speak with to get access?
+Is there a CDN? How does it work?
+Is there a particular release process?
+
+
+Design
+----------------------------------------------
+
+Spot for designers to put any information they need.
+
+
+Known Issues / Gotcha
+----------------------------------------------
+
+
+
+Extended Resources
+----------------------------------------------
+
+link to extended resources
+
>>>>>>> 196bab29633e5c72a7988c9f3afc3ff13021c06c
