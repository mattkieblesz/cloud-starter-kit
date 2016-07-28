# Components

Components encapsulate our software so we can easily without any hard-coding startup desired solution or build new one and test on development, staging and production environments. The best way is to design them agnostic-ally - this will enable maximum reuse and be example of great design.

It is much better to maintain one "web-app-django", "web-app-rails", "static-bootstrap" components rather than "web-app-django-bootstrap" and "web-app-rails-bootstrap" - when we will have new component "static-semantic" this will bring overhead in integrating it into 2 projects.

This is, single repo cloud structure, main value of this project. Because it solves something it also brings overhead - dependency injection.

Imagine you want to add new component, let's say it's database with support of clustering. And we want to couple this component with web app component. Obviously web app component needs to know how to talk to multiple databases, and there might be different web app components. We want to keep everything in one place, hence the problem and the solution - build, fault tolerant scripts which handle/modify it's links.

This requires components to be designed in a way where multiple dependencies won't conflict when they will change it's configuration. This will allow to fulfill this project promises.