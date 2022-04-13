## New Features
- [x] Fetch repo data for user
- [x] Make flipable cards
- [x] Add most used language
- [x] Add loading spinner
- [ ] Make profile data clickable
- [ ] Recent searches
- [x] Handle API errors
- [ ] Handle pagination in repos API
- [x] Handle empty events api response
- [x] Mobile friendly UI

## Refactoring
- [x] Create separate module for repository stats
- [ ] Handle race condition with 3 API calls + searching state
- [ ] Better handle storing of repos and activity data
  - [x] Nest data under profile record
  - [x] In the update function, do something like the below to build the new profile
    ```elm
      { model | profile = (setProfileActivity model.profile activity) }
    ```
  - [ ] Set repos to `Nothing` when empty array is returned from API
- [ ] Write tests for backend