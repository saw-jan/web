Feature: User can see the file or folder actions menu options
  As a user
  I want to be able to see the actions menu options of file or folder
  So that the menu options of the selected file type or folder are visible to me

Background: prepare user and files
    Given user "user1" has been created with default attributes
    And user "user1" has logged in using the webUI
    And the user has browsed to the files page
    
  Scenario: observe different actions menu options on selecting different file types or folder
    Given user "user1" has uploaded file with content "pdf file" to "lorem.pdf"
    And the user has reloaded the current page of the webUI
    And the app-sidebar for file "lorem.txt" has been visible on the webUI
    When the user picks the row of folder "simple-folder" in the webUI
    Then the app-sidebar for folder "simple-folder" should be visible on the webUI
    And only the following items with default items should be visible in the actions menu on the webUI
      | items                     |
      | open folder               |
    When the user picks the row of file "lorem.txt" in the webUI
    Then the app-sidebar for file "lorem.txt" should be visible on the webUI
    And only the following items with default items should be visible in the actions menu on the webUI
      | items                     |
      | open in markdowneditor    |
      | download                  |
    When the user picks the row of file "lorem.pdf" in the webUI
    Then the app-sidebar for file "lorem.pdf" should be visible on the webUI
    And only the following items with default items should be visible in the actions menu on the webUI
      | items                     |
      | open in browser           |
      | download                  |
    When the user picks the row of file "testavatar.png" in the webUI
    Then the app-sidebar for file "testavatar.png" should be visible on the webUI
    And only the following items with default items should be visible in the actions menu on the webUI
      | items                     |
      | open in mediaviewer       |
      | download                  |
    