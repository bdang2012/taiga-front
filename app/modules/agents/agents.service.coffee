taiga = @.taiga

class AgentsService extends taiga.Service
    @.$inject = ["tgResources", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @projectUrl, @lightboxFactory) ->

angular.module("taigaAgents").service("tgAgentsService", AgentsService)