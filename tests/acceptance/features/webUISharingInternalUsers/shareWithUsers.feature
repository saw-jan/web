@ocis-reva-issue-64
Feature: Sharing files and folders with internal users
  As a user
  I want to share files and folders with other users
  So that those users can access the files and folders

  Background:
    Given the setting "shareapi_auto_accept_share" of app "core" has been set to "no"
    And the administrator has set the default folder for received shares to "Shares"
    And these users have been created with default attributes:
      | username |
      | user1    |
      | user2    |

  @yetToImplement @smokeTest @issue-ocis-717
  Scenario Outline: share a file & folder with another internal user
    Given user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "simple-folder" offered by user "user2" using the sharing API
    And the user shares file "testimage.jpg" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "testimage.jpg" offered by user "user2" using the sharing API
    Then user "User One" should be listed as "<expected-role>" in the collaborators list for folder "simple-folder" on the webUI
    And user "User One" should be listed as "<expected-role>" in the collaborators list for file "testimage.jpg" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                 |
      | uid_owner   | user2                 |
      | share_with  | user1                 |
      | file_target | /Shares/simple-folder |
      | item_type   | folder                |
      | permissions | <permissions-folder>  |
    And user "user1" should have received a share with these details:
      | field       | value                 |
      | uid_owner   | user2                 |
      | share_with  | user1                 |
      | file_target | /Shares/testimage.jpg |
      | item_type   | file                  |
      | permissions | <permissions-file>    |
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    Then these files should be listed on the webUI
      | files         |
      | simple-folder |
      | testimage.jpg |
    And these resources should be listed in the folder "/Shares%2Fsimple-folder" on the webUI
      | entry_name |
      | lorem.txt  |
    But these resources should not be listed in the folder "/Shares%2Fsimple-folder" on the webUI
      | entry_name    |
      | simple-folder |
    #    And folder "simple-folder (2)" should be marked as shared by "User Two" on the webUI
    #    And file "testimage (2).jpg" should be marked as shared by "User Two" on the webUI
    Examples:
      | set-role             | expected-role        | permissions-folder              | permissions-file  |
      | Viewer               | Viewer               | read,share                      | read, share       |
      | Editor               | Editor               | read,update,create,delete,share | read,update,share |
      | Advanced permissions | Advanced permissions | read                            | read              |

  @issue-ocis-717
  Scenario Outline: change the collaborators of a file & folder
    Given user "user2" has logged in using the webUI
    And user "user2" has shared folder "/simple-folder" with user "user1" with "<initial-permissions>" permissions
    And user "user1" has accepted the share "simple-folder" offered by user "user2"
    When the user changes the collaborator role of "User One" for folder "simple-folder" to "<set-role>" using the webUI
    # check role without reloading the collaborators panel, see issue #1786
    Then user "User One" should be listed as "<expected-role>" in the collaborators list on the webUI
    # check role after reopening the collaborators panel
    And user "User One" should be listed as "<expected-role>" in the collaborators list for folder "simple-folder" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                  |
      | uid_owner   | user2                  |
      | share_with  | user1                  |
      | file_target | /Shares/simple-folder  |
      | item_type   | folder                 |
      | permissions | <expected-permissions> |
    Examples:
      | initial-permissions | set-role             | expected-role | expected-permissions            |
      | read,update,create  | Viewer               | Viewer        | read,share                      |
      | read                | Editor               | Editor        | read,update,create,delete,share |
      | read,share          | Advanced permissions | Viewer        | read,share                      |
      | all                 | Advanced permissions | Editor        | all                             |

  @skipOnOC10 @issue-ocis-717
  #after fixing the issue delete this scenario and use the one above by deleting the @skipOnOCIS tag there
  Scenario Outline: change the collaborators of a file & folder
    Given user "user2" has logged in using the webUI
    And user "user2" has shared folder "/simple-folder" with user "user1" with "<initial-permissions>" permissions
    And user "user1" has accepted the share "simple-folder" offered by user "user2"
    When the user changes the collaborator role of "User One" for folder "simple-folder" to "<set-role>" using the webUI
    # check role without reloading the collaborators panel, see issue #1786
    Then user "User One" should be listed as "<expected-role>" in the collaborators list on the webUI
    # check role after reopening the collaborators panel
    And user "User One" should be listed as "<expected-role>" in the collaborators list for folder "simple-folder" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                  |
      | uid_owner   | user2                  |
      | share_with  | user1                  |
      | file_target | /Shares/simple-folder  |
      | item_type   | folder                 |
      | permissions | <expected-permissions> |
    Examples:
      | initial-permissions       | set-role             | expected-role | expected-permissions      |
      | read,update,create        | Viewer               | Viewer        | read                      |
      | read                      | Editor               | Editor        | read,update,create,delete |
      | read                      | Advanced permissions | Viewer        | read                      |
      | read,update,create,delete | Advanced permissions | Editor        | read,update,create,delete |

  @skip @issue-4102
  Scenario: share a file with another internal user who overwrites and unshares the file
    Given user "user2" has logged in using the webUI
    And user "user2" has renamed file "lorem.txt" to "new-lorem.txt"
    And user "user2" has shared file "new-lorem.txt" with user "user1" with "all" permissions
    And user "user1" has accepted the share "new-lorem.txt" offered by user "user2"
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    Then as "user1" the content of "Shares/new-lorem.txt" should not be the same as the local "new-lorem.txt"
    # overwrite the received shared file
    When the user uploads overwriting file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should be listed on the webUI
    And as "user1" the content of "Shares/new-lorem.txt" should be the same as the local "new-lorem.txt"
    # unshare the received shared file
    When the user deletes file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should not be listed on the webUI
    # check that the original file owner can still see the file
    And as "user2" the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"


  Scenario: share a folder with another internal user who uploads, overwrites and deletes files
    Given user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" as "Editor" using the webUI
    And user "user1" accepts the share "simple-folder" offered by user "user2" using the sharing API
    And the user re-logs in as "user1" using the webUI
    And the user browses to the folder "Shares" on the files page
    And the user opens folder "simple-folder" using the webUI
    Then as "user1" the content of "Shares/simple-folder/lorem.txt" should not be the same as the local "lorem.txt"
    # overwrite an existing file in the received share
    When the user uploads overwriting file "lorem.txt" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user1" the content of "Shares/simple-folder/lorem.txt" should be the same as the local "lorem.txt"
    # upload a new file into the received share
    When the user uploads file "new-lorem.txt" using the webUI
    Then as "user1" the content of "Shares/simple-folder/new-lorem.txt" should be the same as the local "new-lorem.txt"
    # delete a file in the received share
    When the user deletes file "data.zip" using the webUI
    Then file "data.zip" should not be listed on the webUI
    # check that the file actions by the sharee are visible for the share owner
    When the user re-logs in as "user2" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user2" the content of "simple-folder/lorem.txt" should be the same as the local "lorem.txt"
    And file "new-lorem.txt" should be listed on the webUI
    And as "user2" the content of "simple-folder/new-lorem.txt" should be the same as the local "new-lorem.txt"
    But file "data.zip" should not be listed on the webUI

  @issue-product-270
  Scenario: share a folder with another internal user who unshares the folder
    Given user "user2" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with user "User One" as "Editor" using the webUI
    And user "user1" accepts the share "new-simple-folder" offered by user "user2" using the sharing API
    # unshare the received shared folder and check it is gone
    And the user re-logs in as "user1" using the webUI
    And the user browses to the folder "Shares" on the files page
    Then folder "new-simple-folder" should be listed on the webUI
    And the user deletes folder "new-simple-folder" using the webUI
    Then folder "new-simple-folder" should not be listed on the webUI
    # check that the folder is still visible for the share owner
    When the user re-logs in as "user2" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    And as "user2" the content of "new-simple-folder/lorem.txt" should be the same as the original "simple-folder/lorem.txt"

  @issue-product-270
  Scenario: share a folder with another internal user and prohibit deleting
    Given user "user2" has logged in using the webUI
    And user "user2" has shared folder "simple-folder" with user "user1" with "create, read, share" permissions
    And user "user1" has accepted the share "simple-folder" offered by user "user2"
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @issue-#4192
  Scenario: share a folder with other user and then it should be listed on Shared with You for other user
    Given user "user2" has renamed folder "simple-folder" to "new-simple-folder"
    And user "user2" has renamed file "lorem.txt" to "ipsum.txt"
    And user "user2" has shared file "ipsum.txt" with user "user1"
    And user "user1" has accepted the share "ipsum.txt" offered by user "user2"
    And user "user2" has shared folder "new-simple-folder" with user "user1"
    And user "user1" has accepted the share "new-simple-folder" offered by user "user2"
    And user "user1" has logged in using the webUI
    When the user browses to the shared-with-me page
    Then file "ipsum.txt" should be listed on the webUI
    And folder "new-simple-folder" should be listed on the webUI


  Scenario: share a folder with other user and then it should be listed on Shared with Others page
    Given user "user3" has been created with default attributes
    And user "user2" has logged in using the webUI
    And user "user2" has shared file "lorem.txt" with user "user1"
    And user "user1" has accepted the share "lorem.txt" offered by user "user2"
    And user "user2" has shared folder "simple-folder" with user "user1"
    And user "user1" has accepted the share "simple-folder" offered by user "user2"
    And user "user2" has shared folder "simple-folder" with user "user3"
    And user "user3" has accepted the share "simple-folder" offered by user "user2"
    When the user browses to the shared-with-others page
    Then the following resources should have the following collaborators
      | fileName      | expectedCollaborators |
      | lorem.txt     | User One              |
      | simple-folder | User One, User Three  |

  @issue-2480 @yetToImplement
  Scenario: check file with same name but different paths are displayed correctly in shared with others page
    Given user "user2" has shared file "lorem.txt" with user "user1"
    And user "user2" has shared file "simple-folder/lorem.txt" with user "user1"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-others page
    Then file "lorem.txt" should be listed on the webUI
#    Then file "lorem.txt" with path "" should be listed in the shared with others page on the webUI
#    And file "lorem.txt" with path "/simple-folder" should be listed in the shared with others page on the webUI

  @issue-4193
  Scenario: user shares the file/folder with another internal user and delete the share with user
    Given user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    And user "user2" has accepted the share "lorem.txt" offered by user "user1"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Two" should be listed as "Editor" in the collaborators list on the webUI
    And as "user2" file "Shares/lorem.txt" should exist
    When the user deletes "User Two" as collaborator for the current file using the webUI
    Then user "User Two" should not be listed in the collaborators list on the webUI
    And file "lorem.txt" should not be listed in shared-with-others page on the webUI
    And as "user2" file "Shares/lorem.txt" should not exist

  @issue-4193
  Scenario: user shares the file/folder with multiple internal users and delete the share with one user
    Given user "user3" has been created with default attributes
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    And user "user2" has accepted the share "lorem.txt" offered by user "user1"
    And user "user1" has shared file "lorem.txt" with user "user3"
    And user "user3" has accepted the share "lorem.txt" offered by user "user1"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Two" should be listed as "Editor" in the collaborators list on the webUI
    And user "User Three" should be listed as "Editor" in the collaborators list on the webUI
    And as "user2" file "Shares/lorem.txt" should exist
    And as "user3" file "Shares/lorem.txt" should exist
    When the user deletes "User Two" as collaborator for the current file using the webUI
    Then user "User Two" should not be listed in the collaborators list on the webUI
    And user "User Three" should be listed as "Editor" in the collaborators list on the webUI
    And file "lorem.txt" should be listed in shared-with-others page on the webUI
    And as "user2" file "Shares/lorem.txt" should not exist
    But as "user3" file "Shares/lorem.txt" should exist


  Scenario: send share shows up on shared-with-others page
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has logged in using the webUI
    When the user browses to the shared-with-others page using the webUI
    Then folder "simple-folder" should be listed on the webUI
    But file "data.zip" should not be listed on the webUI


  Scenario: received share shows up on shared-with-me page
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-me page using the webUI
    Then folder "simple-folder" should be listed on the webUI
    But file "data.zip" should not be listed on the webUI

  @issue-4170
  Scenario: clicking a folder on shared-with-me page jumps to the main file list inside the folder
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user1" has created file "simple-folder/collaborate-on-this.txt"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-me page using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then file "collaborate-on-this.txt" should be listed on the webUI

  @issue-ocis-730
  Scenario: deleting an entry on the shared-with-me page unshares from self
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-me page using the webUI
    And the user deletes folder "simple-folder" using the webUI
    And the user browses to the folder "Shares" on the files page
    Then folder "simple-folder" should not be listed on the webUI

  @issue-ocis-730
  Scenario: deleting multiple entries on the shared-with-me page
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user1" has shared file "lorem.txt" with user "user2"
    And user "user2" has accepted the share "lorem.txt" offered by user "user1"
    And user "user2" has logged in using the webUI
    And the user browses to the shared-with-me page using the webUI
    When the user batch deletes these files using the webUI
      | name          |
      | simple-folder |
      | lorem.txt     |
    Then the deleted elements should not be listed on the webUI


  Scenario: Try to share file and folder that used to exist but does not anymore
    Given user "user1" has logged in using the webUI
    And the following files have been deleted by user "user1"
      | name          |
      | lorem.txt     |
      | simple-folder |
    When the user shares file "lorem.txt" with user "User Two" as "Editor" using the webUI
    Then the error message with header 'Error while sharing.' should be displayed on the webUI
    And user "UserTwo" should not be listed in the collaborators list on the webUI
    When the user clears all error message from the webUI
    And the user shares folder "simple-folder" with user "User Two" as "Editor" using the webUI
    Then the error message with header 'Error while sharing.' should be displayed on the webUI
    And user "UserTwo" should not be listed in the collaborators list on the webUI
    When the user reloads the current page of the webUI
    Then file "lorem.txt" should not be listed on the webUI
    And folder "simple-folder" should not be listed on the webUI
    And as "user1" file "lorem.txt" should not exist
    And as "user1" folder "simple-folder" should not exist

  @issue-2897 @issue-4193
  Scenario: sharing details of items inside a shared folder
    Given user "user3" has been created with default attributes
    And user "user1" has uploaded file with content "test" to "/simple-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has logged in using the webUI
    And the user opens folder "simple-folder" using the webUI
    When the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User Two" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Two" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI

  # Share permission is not available in oCIS webUI so when setting all permissions, it is displayed as "Advanced permissions" there
  @issue-2897
  Scenario: sharing details of items inside a re-shared folder
    Given user "user3" has been created with default attributes
    And user "user1" has uploaded file with content "test" to "/simple-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with user "user3"
    And user "user2" has logged in using the webUI
    And the user has opened folder "Shares"
    And the user has opened folder "simple-folder"
    When the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User Three" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Three" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI

  @skipOnOC10 @issue-2897
  Scenario: sharing details of items inside a re-shared folder
    Given user "user3" has been created with default attributes
    And user "user1" has uploaded file with content "test" to "/simple-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with user "user3"
    And user "user2" has logged in using the webUI
    And the user has opened folder "Shares"
    And the user has opened folder "simple-folder"
    When the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User Three" should be listed as "Advanced permissions" via "simple-folder" in the collaborators list on the webUI
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Three" should be listed as "Advanced permissions" via "simple-folder" in the collaborators list on the webUI

  @issue-2897 @issue-4193
  Scenario: sharing details of items inside a shared folder shared with multiple users
    Given user "user3" has been created with default attributes
    And user "user1" has created folder "/simple-folder/sub-folder"
    And user "user1" has uploaded file with content "test" to "/simple-folder/sub-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has shared folder "simple-folder/sub-folder" with user "user3"
    And user "user1" has logged in using the webUI
    And the user opens folder "simple-folder/sub-folder" directly on the webUI
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Two" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI
    And user "User Three" should be listed as "Editor" via "sub-folder" in the collaborators list on the webUI

  @issue-2898
  Scenario: see resource owner in collaborators list for direct shares
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has logged in using the webUI
    And the user has opened folder "Shares"
    When the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User One" should be listed as "Owner" in the collaborators list on the webUI

  @issue-2898
  Scenario: see resource owner in collaborators list for reshares
    Given user "user3" has been created with default attributes
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with user "user3"
    And user "user3" has accepted the share "simple-folder" offered by user "user2"
    And user "user3" has logged in using the webUI
    And the user has opened folder "Shares"
    When the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User One" should be listed as "Owner" reshared through "User Two" in the collaborators list on the webUI
    And the current collaborators list should have order "User One,User Three"

  @issue-2898 @issue-4168
  Scenario: see resource owner of parent shares in collaborators list
    Given user "user3" has been created with default attributes
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with user "user3"
    And user "user3" has accepted the share "simple-folder" offered by user "user2"
    And user "user3" has logged in using the webUI
    And the user has opened folder "Shares"
    And the user has opened folder "simple-folder"
    When the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User One" should be listed as "Owner" reshared through "User Two" via "simple-folder" in the collaborators list on the webUI
    And the current collaborators list should have order "User One,User Three"

  @issue-3040 @issue-4113 @ocis-reva-issue-39
  Scenario: see resource owner of parent shares in "shared with others" and "favorites" list
    Given user "user3" has been created with default attributes
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder/simple-empty-folder" with user "user3"
    And user "user2" has favorited element "Shares/simple-folder/simple-empty-folder"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-others page
    And the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User One" should be listed as "Owner" via "simple-folder" in the collaborators list on the webUI
    When the user browses to the favorites page using the webUI
    And the user opens the share dialog for folder "…/simple-folder/simple-empty-folder" using the webUI
    Then user "User One" should be listed as "Owner" via "simple-folder" in the collaborators list on the webUI

  @issue-2898 @ocis-issue-891
  Scenario: see resource owner for direct shares in "shared with me"
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user browses to the shared-with-me page
    And the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User One" should be listed as "Owner" in the collaborators list on the webUI

  @issue-ocis-reva-41
  Scenario Outline: collaborators list contains additional info when enabled
    Given the setting "user_additional_info_field" of app "core" has been set to "<additional-info-field>"
    And user "user1" has shared folder "simple-folder" with user "user2"
    When user "user1" has logged in using the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User Two" should be listed with additional info "<additional-info-result>" in the collaborators list on the webUI
    Examples:
      | additional-info-field | additional-info-result |
      | id                    | user2                  |
      | email                 | user2@example.org      |


  Scenario: collaborators list does not contain additional info when disabled
    Given the setting "user_additional_info_field" of app "core" has been set to ""
    And user "user1" has shared folder "simple-folder" with user "user2"
    When user "user1" has logged in using the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User Two" should be listed without additional info in the collaborators list on the webUI


  Scenario: collaborators list contains the current user when they are an owner
    Given user "user1" has shared folder "simple-folder" with user "user2"
    When user "user1" has logged in using the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User One" should be listed with additional info "(me)" in the collaborators list on the webUI


  Scenario: collaborators list contains the current user when they are a receiver of the resource
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user opens folder "Shares" using the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    Then user "User Two" should be listed with additional info "(me)" in the collaborators list on the webUI

  @issue-ocis-reva-34
  Scenario: current user should see the highest role in their entry in collaborators list
    Given group "grp1" has been created
    And user "user2" has been added to group "grp1"
    And user "user1" has shared folder "simple-folder" with user "user2" with "read" permission
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user1" has shared folder "simple-folder" with group "grp1" with "read,update,create,delete" permissions
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    When user "user2" logs in using the webUI
    And the user opens folder "Shares" using the webUI
    Then user "User Two" should be listed as "Advanced permissions" in the collaborators list for folder "simple-folder (2)" on the webUI


  Scenario: share a file with another internal user via collaborators quick action
    Given user "user1" has logged in using the webUI
    When the user shares resource "simple-folder" with user "User Two" using the quick action in the webUI
    And user "user2" accepts the share "simple-folder" offered by user "user1" using the sharing API
    Then user "User Two" should be listed as "Viewer" in the collaborators list for folder "simple-folder" on the webUI
    And user "user2" should have received a share with these details:
      | field       | value                 |
      | uid_owner   | user1                 |
      | share_with  | user2                 |
      | file_target | /Shares/simple-folder |
      | item_type   | folder                |
      | permissions | read,share            |


  Scenario Outline: Share files/folders with special characters in their name
    Given user "user2" has created folder "Sample,Folder,With,Comma"
    And user "user2" has created file "sample,1.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "Sample,Folder,With,Comma" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "Sample,Folder,With,Comma" offered by user "user2" using the sharing API
    And the user shares file "sample,1.txt" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "sample,1.txt" offered by user "user2" using the sharing API
    Then user "User One" should be listed as "<expected-role>" in the collaborators list for folder "Sample,Folder,With,Comma" on the webUI
    And user "User One" should be listed as "<expected-role>" in the collaborators list for file "sample,1.txt" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                            |
      | uid_owner   | user2                            |
      | share_with  | user1                            |
      | file_target | /Shares/Sample,Folder,With,Comma |
      | item_type   | folder                           |
      | permissions | <permissions-folder>             |
    And user "user1" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user2                |
      | share_with  | user1                |
      | file_target | /Shares/sample,1.txt |
      | item_type   | file                 |
      | permissions | <permissions-file>   |
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    Then these files should be listed on the webUI
      | files                    |
      | Sample,Folder,With,Comma |
      | sample,1.txt             |
    Examples:
      | set-role             | expected-role        | permissions-folder              | permissions-file  |
      | Viewer               | Viewer               | read,share                      | read,share        |
      | Editor               | Editor               | read,update,create,delete,share | read,update,share |
      | Advanced permissions | Advanced permissions | read                            | read              |

  @skipOnOC10
  #after fixing the issue delete this scenario and use the one above by deleting the @skipOnOCIS tag there
  Scenario Outline: Share files/folders with special characters in their name
    Given user "user2" has created folder "Sample,Folder,With,Comma"
    And user "user2" has created file "sample,1.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "Sample,Folder,With,Comma" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "Sample,Folder,With,Comma" offered by user "user2" using the sharing API
    And the user shares file "sample,1.txt" with user "User One" as "<set-role>" using the webUI
    And user "user1" accepts the share "sample,1.txt" offered by user "user2" using the sharing API
    Then user "User One" should be listed as "<expected-role>" in the collaborators list for folder "Sample,Folder,With,Comma" on the webUI
    And user "User One" should be listed as "<expected-role>" in the collaborators list for file "sample,1.txt" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                            |
      | uid_owner   | user2                            |
      | share_with  | user1                            |
      | file_target | /Shares/Sample,Folder,With,Comma |
      | item_type   | folder                           |
      | permissions | <permissions-folder>             |
    And user "user1" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user2                |
      | share_with  | user1                |
      | file_target | /Shares/sample,1.txt |
      | item_type   | file                 |
      | permissions | <permissions-file>   |
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    Then these files should be listed on the webUI
      | files                    |
      | Sample,Folder,With,Comma |
      | sample,1.txt             |
    Examples:
      | set-role             | expected-role | permissions-folder        | permissions-file |
      | Viewer               | Viewer        | read                      | read             |
      | Editor               | Editor        | read,update,create,delete | read,update      |
      | Advanced permissions | Viewer        | read                      | read             |

  Scenario: file list view image preview in file share
    Given user "user1" has uploaded file "testavatar.jpg" to "testavatar.jpg"
    And user "user1" has shared file "testavatar.jpg" with user "user2"
    And user "user2" has accepted the share "testavatar.jpg" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user opens folder "Shares" using the webUI
    Then the preview image of file "testavatar.jpg" should be displayed in the file list view on the webUI

  Scenario: file list view image preview in file share when previews is disabled
    Given the property "disablePreviews" of "options" has been set to true in web config file
    And user "user1" has uploaded file "testavatar.jpg" to "testavatar.jpg"
    And user "user1" has shared file "testavatar.jpg" with user "user2"
    And user "user2" has accepted the share "testavatar.jpg" offered by user "user1"
    And user "user2" has logged in using the webUI
    When the user opens folder "Shares" using the webUI
    Then the preview image of file "testavatar.jpg" should not be displayed in the file list view on the webUI
