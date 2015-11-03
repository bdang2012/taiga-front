class UsersListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgUsersService",
    ]

    constructor: (@currentUserService, @usersService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))
        taiga.defineImmutableProperty(@, "users", () => @usersService.getInventory())

    newProject: ->
        @usersService.newProject()
angular.module("taigaUsers").controller("UsersListing", UsersListingController)
