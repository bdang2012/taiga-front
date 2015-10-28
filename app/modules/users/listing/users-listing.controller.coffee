class UsersListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgUsersService",
    ]

    constructor: (@currentUserService, @usersService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))

    newProject: ->
        @usersService.newProject()
angular.module("taigaUsers").controller("UsersListing", UsersListingController)
