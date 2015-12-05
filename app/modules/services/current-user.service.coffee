taiga = @.taiga

groupBy = @.taiga.groupBy

class CurrentUserService
    @.$inject = [
        "tgProjectsService",
        "$tgStorage"
    ]

    constructor: (@projectsService, @storageService) ->
        @._user = null
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()
        @._inventory = Immutable.Map()

        taiga.defineImmutableProperty @, "projects", () => return @._projects
        taiga.defineImmutableProperty @, "projectsById", () => return @._projectsById
        taiga.defineImmutableProperty @, "inventory", () => return @._inventory

    isAuthenticated: ->
        if @.getUser() != null
            return true
        return false

    isProducer: ->
        if !@._user
            return false

        return @._user.get("is_producer")

    isAgent: ->
        if !@._user
            return false
        return @._user.get("is_agent")

    isProducerOrAgent: ->
        return (@.isProducer() or @.isAgent() )

    getUser: () ->
        if !@._user
            userData = @storageService.get("userInfo")

            if userData
                userData = Immutable.fromJS(userData)
                @.setUser(userData)

        return @._user

    removeUser: () ->
        @._user = null
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()

    setUser: (user) ->
        @._user = user

        return @._loadUserInfo()

    bulkUpdateProjectsOrder: (sortData) ->
        @projectsService.bulkUpdateProjectsOrder(sortData).then () =>
            @._loadProjects()

    _loadProjects: () ->
        return @projectsService.getProjectsByUserId(@._user.get("id"))
            .then (projects) =>
                @._projects = @._projects.set("all", projects)

                console.log 'bdlog: '
                console.log @._projects.toJS()

                @._projects = @._projects.set("recents", projects.slice(0, 10))
                @._projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

                return @.projects

    _loadInventory: () ->
        return @projectsService.getInventory()
            .then (inventory) =>
                @._inventory = @._inventory.set("all", inventory)

                console.log 'bdlog: in loadInventory '
                console.log @._inventory.toJS()

                return @.inventory                

    _loadUserInfo: () ->
        @._loadInventory()
        return @._loadProjects()

angular.module("taigaCommon").service("tgCurrentUserService", CurrentUserService)
