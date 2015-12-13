class UsersListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgUsersService",
    ]

    constructor: (@currentUserService, @usersService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))
        taiga.defineImmutableProperty(@, "inventory", () => @currentUserService.inventory.get("all"))


    openActivateAgentLightbox: (user) ->
        if confirm 'Promote this user to be Agent: ' + user.get("full_name") + "?"
            userChanged = user.set("is_agent",true)
            this.usersService.change_is_agent(userChanged)
            location.reload()

    newProject: ->
        @usersService.newProject()
angular.module("taigaUsers").controller("UsersListing", UsersListingController)
