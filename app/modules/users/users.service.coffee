taiga = @.taiga
groupBy = @.taiga.groupBy

class UsersService extends taiga.Service
    @.$inject = ["tgResources", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @projectUrl, @lightboxFactory) ->

    change_is_agent: (user) ->
        return @rs.users.change_is_agent(user)
            
    getProjectBySlug: (projectSlug) ->
        return @rs.projects.getProjectBySlug(projectSlug)
            .then (project) =>
                return @._decorate(project)

    getProjectStats: (projectId) ->
        return @rs.projects.getProjectStats(projectId)

    getProjectsByUserId: (userId, paginate) ->
        return @rs.projects.getProjectsByUserId(userId, paginate)
            .then (projects) =>
                return projects.map @._decorate.bind(@)

    getAgents: (paginate) ->
        return @rs.users.getAgents(paginate)
            .then (agents) =>
                return agents.map @._decorate.bind(@)

    getInventory: (paginate) ->
        return @rs.projects.getInventory(paginate)
            .then (projects) =>
                return projects.map @._decorate.bind(@)

    _decorate: (project) ->
        url = @projectUrl.get(project.toJS())

        project = project.set("url", url)
        colorized_tags = []

        if project.get("tags")
            tags = project.get("tags").sort()

            colorized_tags = tags.map (tag) ->
                color = project.get("tags_colors").get(tag)
                return Immutable.fromJS({name: tag, color: color})

            project = project.set("colorized_tags", colorized_tags)

        return project

    newProject: ->
        @lightboxFactory.create("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        return @rs.projects.bulkUpdateOrder(sortData)

angular.module("taigaUsers").service("tgUsersService", UsersService)