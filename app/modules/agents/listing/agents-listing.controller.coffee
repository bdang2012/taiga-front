class AgentsListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgUsersService",
    ]

    constructor: (@currentUserService, @usersService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))
        taiga.defineImmutableProperty(@, "inventory", () => @currentUserService.inventory.get("all"))
        taiga.defineImmutableProperty(@, "agents", () => @currentUserService.agents.get("all"))

    openDeactivateAgentLightbox: (user) ->
        if confirm 'Are you sure you want to deactivate Agent ' + user.get("full_name") + "?"
            alert('will do the deactiate and reload page')
            this.usersService.getAgents()
            location.reload()
        
    newProject: ->
        @usersService.newProject()
angular.module("taigaAgents").controller("AgentsListing", AgentsListingController)