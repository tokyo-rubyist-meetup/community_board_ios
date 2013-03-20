# Define the Data Model

Find the file “CommunityBoard.xcdatamodeld”.  This is the file you will use to create the data model for your project.

The Community Board project has three basic objects: communities, posts, and users.  Therefore, you will want to make three entities in the Core Data editor.

	- Community
	- Post
	- User

## Community

The Community entity should have four attributes:

	- createdAt

This is the date in which the community was created, so it should be a Date type.

	- name

This is the name of the community, so it should be a String.

	- communityId

This is the identifier for the community.  Since ‘id’ is a reserved word in Objective C, we give it the name “communityId” instead.  Identifiers in this project are integers, so this should be an Integer type.

On the right-hand side, you might want to check the box to make this value “indexed,” which will improve the speed with which Core Data can access this value.

	- postCount

This is the number of posts that are currently listed under that community.  It should also be an Integer.

and one relationship

	- posts

Make sure that the posts relationship is a to-many relationship because, for one community, there will be many posts.

## Post

The Post entity should three attributes:

	- createdAt

This is the date in which the post was created, so it should be a Date type.

	- text

This is the text for the post.  It should be a String.

	- postId

Similiar to communityId above.

It will have two relationships.

	- community
	- user

Make sure that the community has an inverse relationship with “posts” on the Community entity.

## User

The User entity should have three attributes

	- avatarURL (String)
	- name (String)
	- userId (Integer)

It should also have one relationship

	- posts

This should also be a “to-many” relationship and should have an inverse relationship to “user” on the posts entity.

## Generating the NSManagedObject subclasses

In XCode, you may also want to make sure that, under Entity in the Data Model inspector that the entity "Community" has a class name `CBCommunity`, "Post" is `CBPost` and "User" is `CBUser`.  (This is done by highlighting each Entity name and find the Data Model inspector which is usually on the right hand side of the screen).

That way, after we generate the model code in the next step, they will have the same name as I use in the rest of the tutorial.  Otherwise, you will need to make sure to use class names that XCode uses. 

Under “File > New > File > Core Data,” you can use the option to `NSManagedObject` subclass in order to generate class based on the data model information you have just created.  Add these classes to the “Model” folder.

# Defining the API

In `CBAppDelegate.m`, there are three empty string constants: `baseURLString`, `applicationID`, `secret`.

You will want to fill in `baseURLString` using the base url for the API of your server (for example, https://community-board.herokuapp.com/api/v1/).

## OAuth

Configuring OAuth requires having an application token and an application secret.  These need to be provided by the server to which you are connecting.

Fortunately, RestKit uses the library AFNetworking under the hood.  AFNetworking has a class called AFHTTPClient which it uses to describe REST APIs and there is a subclass of AFHTTPClient called AFOAuth2Client which can handle all of the implementation details for us.  So implementing OAuth2 is as easy as creating an AFOAuth2Client, setting it as RestKit's HTTP client, and then calling the relevent methods. 

In `CBAppDelegate.m`, fill in the `applicationID` and `secret` with the values which have been provided to you.

Next add the following lines, which will setup a new `AFOAuth2Client` and `CBObjectManager` which uses that client as its http client.

    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:baseURL clientID:applicationID secret:secret];
    [oauthClient setParameterEncoding:AFJSONParameterEncoding];
  
    CBObjectManager *objectManager = [[CBObjectManager alloc] initWithHTTPClient:oauthClient];
    objectManager.managedObjectStore = self.managedObjectStore;
    [objectManager setup];
    
    if (!credential) {
      rootViewController = [[CBLoginViewController alloc] initWithNibName:nil bundle:nil];
    } else {
      [oauthClient setAuthorizationHeaderWithCredential:credential];
      rootViewController = [[CBCommunityViewController alloc] initWithManagedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
    }

Next, in `CBAPI.m`, you will see a method called `+ (NSString*) authenticationPath`.  This method should return the path on the server to perform authentication (for example,
    
    + (NSString*)communitiesPath {
        return @"oauth/token";
    }
    
) Fill in this value with the authenticationPath on your server.

Now, we can follow the OAuth flow like this:

When the application starts up, it will run `application:didFinishLaunchingWithOptions:` in CBAppDelegate.m.  Inside of this method, the line

      AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:CBCredentialIdentifier];

will check to see if there is an OAuth token already stored on this device.  If there is already a credential, it tells the `AFOAuth2Client` to sign all of our requests using those creditials automatically, so we can access the server apis from this point on without any problem.

If there is not a credential already, however, it will display a `CBLoginViewController` to use the user’s e-mail and password to obtain the credential.

Find the method called `- (void)authenticateWithUsername:password:` and add the following code inside of it:

    CBLoginViewController *__weak weakSelf = self;

    [(AFOAuth2Client*)[CBObjectManager sharedManager].HTTPClient authenticateUsingOAuthWithPath:[CBAPI authenticationPath]
      username:username
      password:password
      scope:nil
      success:^(AFOAuthCredential *credential){
        [AFOAuthCredential storeCredential:credential withIdentifier:CBCredentialIdentifier];
      
        CBCommunityViewController *rootViewController = [[CBCommunityViewController alloc]
          initWithManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
        [weakSelf.navigationController setViewControllers:@[rootViewController] animated:YES];
      }
      failure:^(NSError *error){
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Error", @"Error")
          message:[error localizedDescription]
          delegate:nil
          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
          otherButtonTitles:nil, nil] show];
      }];

The authentication is done with the method `authenticateUsingOAuthWithPath:username:password:scope:success:failure:`.  When we run this method, it sends the username and password to the server and returns the OAuth credential.  Then we securely store the credential on the User’s Keychain with storeCredential:withIdentifier: and load the CBCommunityViewController.

## API

In order to access the API, we will need to fill in the remain of the endpoints in CBAPI.m.  Other than authentication, there are two other endpoints we will want to access, the endpoint to get communities and the endpoint to get posts or create a new post.

The communities endpoint is fairly straightforward.  We want should simply change it to return the endpoint which downloads all of the communities.
    
    + (NSString*)communitiesPath {
          return @"communities.json";
    }
    
The post endpoints are more challenging.  Because posts depend on the identifer for the community, we define both the *pattern* for the API as well as a way to fill in the pattern based on a specific community.  RestKit provides a function to do this for us:
 
    + (NSString*)postPathWithCommunity:(CBCommunity *)community {
        return RKPathFromPatternWithObject([self postsPathPattern], community);
    }

    + (NSString*)postsPathPattern {
        return @"communities/:communityId/posts.json";
    }

Now we should have all of the endpoints for the API defined.

# Setting Up RestKit

## Core Data

First, we need to focus our attention on setting up the Core Data layer of RestKit.

In CBAppDelegate.m, we need to set up the `RKManagedObjectStore`.  This is a class which will automatically take care of most of the setup and management of standard Core Data classes, such as the `NSPersistentStoreCoordinator` and the `NSManagedObjectContext`.  

Find the `- (void)managedObjectStore` method on `CBAppDelegate.m` and replace the content with the following lines:

    if (_managedObjectStore) {
      return _managedObjectStore;
    }
  
    _managedObjectStore = [[RKManagedObjectStore alloc]
      initWithManagedObjectModel:self.managedObjectModel];
    [_managedObjectStore createPersistentStoreCoordinator];

    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CommunityBoard.sqlite"];
    NSError *error = nil;
    NSPersistentStore *persistentStore = [_managedObjectStore
      addSQLitePersistentStoreAtPath:storePath
      fromSeedDatabaseAtPath:nil
      withConfiguration:nil
      options:nil
      error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
  
    [_managedObjectStore createManagedObjectContexts];
  
    return _managedObjectStore

This code will tell the `RKManagedObjectStore` to create an `RKManagedObjectStore` using the CommunityBoard data model we have already defined.  It will then use this model to create persistent store coordinators (which regulate how Core Data holds its information, whether in memory, in an SQLite database, or other options).

Next, it tells the `RKManagedObjectStore` to add a new persistent store which will store data in an SQLite database called "CommunityBoard.sqlite" in the Documents folder of the app.

Finally, it generates the default managed object contexts.  RestKit uses two managed object contexts, one which stays in a private queue and stores data to the database, and a child context which stays on the main thread which we interact with in this application.

## Setting Up Entity Mapping

Next, there is a subclass of `RKObjectManager` which has already been prepared.  It is called `CBObjectManager`.  Inside of `CBObjectManager.m` is a method called `- (void)setup`.  The setup for this application will have two main steps.

### Setup the Entity Mappings

First, at the top of the function, add the following code:

#### Community

    RKEntityMapping *communityResponseMapping = [RKEntityMapping
      mappingForEntityForName:@"Community"
      inManagedObjectStore:self.managedObjectStore];
    communityResponseMapping.identificationAttributes = @[ @"communityId" ];
    [communityResponseMapping addAttributeMappingsFromDictionary:@{
      @"id": @"communityId",
      @"created_at": @"createdAt",
      @"post_count": @"postCount"
    }];
    [communityResponseMapping addAttributeMappingsFromArray:@[@"name"]];

This code tells RestKit how to take the results from the JSON we receive from the server and map it to the properties in the Core Data entities that we made before.

The JSON we are expecting has the internal structure

    {
        "id": …,
        "created_at": …,
        "name": …,
        "post_count":…
    }

In `addAttributeMappingsFromDictionary:` the key on the JSON object is matched with an attribute on the entity.  So, the `id` field in the JSON object becomes `communityId` in the `NSManagedObject` subclass.  

Because `name` is the same on both, we can use `addAttributeMappingsFromArray:` to add it without any mapping.

Any fields in the JSON object which are not added to the mappings will be ignored.

#### Post

    RKObjectMapping *postRequestMapping = [RKObjectMapping requestMapping];
    [postRequestMapping addAttributeMappingsFromArray:@[@"text"]];

This code will set up how a post object will be formatted when it is send as a POST *request*.  Essentially, only the `text` attribute is sent.  

    RKEntityMapping *postsResponseMapping = [RKEntityMapping
      mappingForEntityForName:@"Post"
      inManagedObjectStore:self.managedObjectStore];
    postsResponseMapping.identificationAttributes = @[ @"postId" ];
    [postsResponseMapping addAttributeMappingsFromDictionary:@{
      @"id": @"postId",
      @"created_at": @"createdAt",
    }];
    [postsResponseMapping addAttributeMappingsFromArray:@[@"text"]];

This code will set up how a post object will be mapped when it is received as a response.  It will work for a JSON object with the internal an internal structure like this:

    {
        "id": …,
        "created_at": …,
        "text": …
    }

#### User

    RKEntityMapping *userResponseMapping = [RKEntityMapping
      mappingForEntityForName:@"User"
      inManagedObjectStore:self.managedObjectStore];
    userResponseMapping.identificationAttributes = @[ @"userId" ];
    [userResponseMapping addAttributeMappingsFromDictionary:@{
      @"id": @"userId",
      @"avatar_url": @"avatarURL",
    }];
    [userResponseMapping addAttributeMappingsFromArray:@[@"name"]];
  
This code shows to format a user as a response.  It will match a JSON object with the following structure:

    {
        "id": …,
        "avatar_url": …,
        "name": …
    }

    [postsResponseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
      toKeyPath:@"user"
      withMapping:userResponseMapping]];

Because the user is nested inside of a post response, this code tells RestKit to look for the "user" keypath inside of a post object in order to do the mapping.

In other words, when it receives a post JSON object, it will look for the following field

    {
        ...
        "user":{ … }
    }

and match those contents with a User Core Data entity.

### Request and Response Descriptors

Once we have told RestKit how to take a JSON object and map it to a Core Data entity, we will need to tell it which server endpoints should be used with which mappings.  This is done with the `RKRequestDescriptor` and `RKResponseDescriptor` classes.

#### Community

    RKResponseDescriptor *communityResponseDescriptor = [RKResponseDescriptor
      responseDescriptorWithMapping:communityResponseMapping
      pathPattern:[CBAPI communitiesPath]
      keyPath:@"communities"
      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self addResponseDescriptor:communityResponseDescriptor];

This code maps the community response mapping we made above to the communities path in our API.  The `keyPath:` argument indicates that the JSON will look like this:

    {
        "communities": […]
    }

#### Post

Next, we create
  
    RKRequestDescriptor *postRequestDescriptor = [RKRequestDescriptor
      requestDescriptorWithMapping:postRequestMapping
      objectClass:[CBPost class]
      rootKeyPath:@"post"];
    [self addRequestDescriptor:postRequestDescriptor];

This code maps the post request mapping to the post path in our API.  This is the API we use to create new posts

    {
        "post": {
            "text":...
        }
    }

Now, we need to create *two* response descriptors for the post endpoint.  The reason is because we have two operations GET and POST for the same endpoint.  One fetches a list of posts and other receives a new post object as a response to the action of creating a new post.  The GET request will have a response like this:

{
	"posts": [...]
}

and the POST request will have a response like this

{
	"post": {...}
}

In short, we will need two response descriptors with the same endpoint, the same mapping, but different key paths, as follows:

    RKResponseDescriptor *postResponseDescriptor = [RKResponseDescriptor
      responseDescriptorWithMapping:postsResponseMapping
      pathPattern:[CBAPI postsPathPattern]
      keyPath:@"post"
      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self addResponseDescriptor:postResponseDescriptor];

    RKResponseDescriptor *postsResponseDescriptor = [RKResponseDescriptor
      responseDescriptorWithMapping:postsResponseMapping
      pathPattern:[CBAPI postsPathPattern]
      keyPath:@"posts"
      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self addResponseDescriptor:postsResponseDescriptor];
  
Since User does not have a distinct endpoint, we do not need to setup any request or response descriptors for it.  Hence, in the end, your `setup` method should look like this:

    - (void)setup {
        RKEntityMapping *communityResponseMapping = [RKEntityMapping
          mappingForEntityForName:@"Community"
          inManagedObjectStore:self.managedObjectStore];
        communityResponseMapping.identificationAttributes = @[ @"communityId" ];
        [communityResponseMapping addAttributeMappingsFromDictionary:@{
          @"id": @"communityId",
          @"created_at": @"createdAt",
          @"post_count": @"postCount"
        }];
        [communityResponseMapping addAttributeMappingsFromArray:@[@"name"]];
  
        RKObjectMapping *postRequestMapping = [RKObjectMapping requestMapping];
        [postRequestMapping addAttributeMappingsFromArray:@[@"text"]];
  
        RKEntityMapping *postsResponseMapping = [RKEntityMapping
          mappingForEntityForName:@"Post"
          inManagedObjectStore:self.managedObjectStore];
        postsResponseMapping.identificationAttributes = @[ @"postId" ];
        [postsResponseMapping addAttributeMappingsFromDictionary:@{
          @"id": @"postId",
          @"created_at": @"createdAt",
        }];
        [postsResponseMapping addAttributeMappingsFromArray:@[@"text"]];
  
        RKEntityMapping *userResponseMapping = [RKEntityMapping
          mappingForEntityForName:@"User"
          inManagedObjectStore:self.managedObjectStore];
        userResponseMapping.identificationAttributes = @[ @"userId" ];
        [userResponseMapping addAttributeMappingsFromDictionary:@{
          @"id": @"userId",
          @"avatar_url": @"avatarURL",
        }];
        [userResponseMapping addAttributeMappingsFromArray:@[@"name"]];
        [postsResponseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
          toKeyPath:@"user"
          withMapping:userResponseMapping]];
  
        RKResponseDescriptor *communityResponseDescriptor = [RKResponseDescriptor
          responseDescriptorWithMapping:communityResponseMapping
          pathPattern:[CBAPI communitiesPath]
          keyPath:@"communities"
          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [self addResponseDescriptor:communityResponseDescriptor];
  
        RKRequestDescriptor *postRequestDescriptor = [RKRequestDescriptor
          requestDescriptorWithMapping:postRequestMapping
          objectClass:[CBPost class]
          rootKeyPath:@"post"];
        [self addRequestDescriptor:postRequestDescriptor];

        RKResponseDescriptor *postsResponseDescriptor = [RKResponseDescriptor
          responseDescriptorWithMapping:postsResponseMapping
          pathPattern:[CBAPI postsPathPattern]
          keyPath:@"posts"
          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [self addResponseDescriptor:postsResponseDescriptor];
  
        RKResponseDescriptor *postResponseDescriptor = [RKResponseDescriptor
          responseDescriptorWithMapping:postsResponseMapping
          pathPattern:[CBAPI postsPathPattern]
          keyPath:@"post"
          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [self addResponseDescriptor:postResponseDescriptor];
    }

# Make the Network Requests

Now all that remains is adding the code to make the various network requests.  There are only three network requests that we are concerned with: loading communities, loading the posts for a given community, and creating a new post in our selected community.

## Loading Communities

In the `CBCommunityViewController.h`, find the method named `- (void)loadCommunities` and add the following code.

    CBCommunityViewController *__weak weakSelf = self;

    [[CBObjectManager sharedManager]
      getObjectsAtPath:[CBAPI communitiesPath]
      parameters:nil
      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      }
      failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading communities: %@", error.localizedDescription);
      }];
      

This instructs RestKit to load the objects at the given path.  Since we have already used an `RKResponseDescriptor` to tell it what to do when we use this path, and we have already showed it how to map the JSON in the response to the Community entity, RestKit will automatically parse the JSON and turn it into `CBCommunity` objects for us.  Furthermore, since we have setup a `NSFetchResultsController` with the same `NSManagedObjectContext`, we don't need to do anything in the success block.  The fetch results controller will automatically detected the changes to the managed object context and reload the data.

## Loading Posts

In the `CBPostViewController.h`, find the method named `- (void)loadCommunities` and add the following code.

    CBPostViewController *__weak weakSelf = self;
  
    [[CBObjectManager sharedManager]
      getObjectsAtPath:[CBAPI postPathWithCommunity:self.community]
      parameters:nil
      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        CBPostViewController *strongSelf = weakSelf;
        NSError *error = nil;
  
        if (strongSelf == nil) {
          return;
        }
          
        strongSelf.posts = [mappingResult.dictionary objectForKey:@"posts"];
        [strongSelf.tableView reloadData];
      
        strongSelf.community.posts = [NSSet setWithArray:strongSelf.posts];
        [strongSelf.managedObjectContext saveToPersistentStore:error];

        if (error) {
          NSLog(@"Error saving posts: %@", error.localizedDescription);
        }
      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading posts: %@", error.localizedDescription);
      }];

This code is almost exactly the same as the previous code.  In this case, we do, actually, have to reload the tableview because the `NSFetchResultsController` follows one specific fetch request.  Here, we are working with a relationship, rather than a fetch request, so we do not get the same automatic behavior.

We also set the relationship between the community and posts here manually and store it.  RestKit actually maintains two managed objects contexts, one which runs in a private queue and one which runs in the main queue, which is a child context of the one running in a private queue.  In this app, we only interact with the managed object context in the main queue and use a convenience method provided by RestKit called `saveToPersistentStore:` which bubbles our changes up to its parent.  This action makes sure that the posts we just loaded are saved in the SQLite database.

One important technical note which is important here:  The success block of this method is called on the main thread and the `self.managedObjectContext` is using `NSMainQueueConcurrencyType`, so it can be used in this manner.  Depending on the concurrency type of a managed object context and whether or not a block is guaranteed to be executed in a particular queue, similiar code might be problematic in other situations.  Please make sure you understand how to use Core Data in a multi-threaded settings such as loading from a network connection.

## Create a New Post

Finally, in `CBCreatePostViewController.m`, find the method called `- (void)createPostWithText:(NSString*)text` and add the following code:

    CBCreatePostViewController *__weak weakSelf = self;
  
    CBPost *post = [NSEntityDescription
      insertNewObjectForEntityForName:@"Post"
      inManagedObjectContext:self.managedObjectContext];
    post.text = text;
        
    [[CBObjectManager sharedManager]
      postObject:post
      path:[CBAPI postPathWithCommunity:self.community]
      parameters:nil
      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        CBCreatePostViewController *strongSelf = weakSelf;
      
        if (strongSelf == nil) {
          return;
        }
    
        [strongSelf.community addPostsObject:post];
        [strongSelf.managedObjectContext saveToPersistentStore:nil];
      
        if ([strongSelf.delegate respondsToSelector:@selector(createPostViewControllerDidCreatePost:)]) {
          [strongSelf.delegate createPostViewControllerDidCreatePost:strongSelf];
        }
      }
      failure:^(RKObjectRequestOperation *operation, NSError *error) {
        CBCreatePostViewController *strongSelf = weakSelf;
      
        if (strongSelf == nil) {
          return;
        }

        [strongSelf.managedObjectContext deleteObject:post];

        if ([strongSelf.delegate respondsToSelector:@selector(createPostViewController:postDidFailWithError:)]) {
          [strongSelf.delegate createPostViewController:strongSelf postDidFailWithError:error];
        }
    }];

This code creates a new post object.  It tries to post the contents of this object.  RestKit will use the `RKRequestDescriptor` that we created previously to format the JSON for the post request.  If the request succeeds, we save the changes locally as well. If it fails, we delete the object locally.

Finally, we call the view controller's delegate methods (which are implemented to dismiss the `CBCreatePostViewController`).
