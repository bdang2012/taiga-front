class AgentsListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgUsersService",
    ]

    constructor: (@currentUserService, @usersService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))
        taiga.defineImmutableProperty(@, "inventory", () => @currentUserService.inventory.get("all"))

    newProject: ->
        @usersService.newProject()
angular.module("taigaAgents").controller("AgentsListing", AgentsListingController)
