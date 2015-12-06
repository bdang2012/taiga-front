Resource = (urlsService, http, paginateResponseService) ->
    service = {}


    service.getInventory = (paginate=false) ->
        url = urlsService.resolve("users")
        httpOptions = {}

        if !paginate
            httpOptions.headers = {
                "x-disable-pagination": "1"
            }

        params = {"order_by": "memberships__user_order"}

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getAgents = (paginate=false) ->
        console.log 'bdlog in users-resource.service'
        url = urlsService.resolve("users")
        httpOptions = {}

        if !paginate
            httpOptions.headers = {
                "x-disable-pagination": "1"
            }

        params = {}

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getUserByUsername = (username) ->
        url = urlsService.resolve("by_username")

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        params = {
            username: username
        }

        return http.get(url, params, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getStats = (userId) ->
        url = urlsService.resolve("stats", userId)

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, {}, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getContacts = (userId) ->
        url = urlsService.resolve("contacts", userId)

        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        return http.get(url, {}, httpOptions)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProfileTimeline = (userId, page) ->
        params = {
            page: page
        }

        url = urlsService.resolve("timeline-profile")
        url = "#{url}/#{userId}"

        return http.get(url, params).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    service.getUserTimeline = (userId, page) ->
        params = {
            page: page
        }

        url = urlsService.resolve("timeline-user")
        url = "#{url}/#{userId}"

        return http.get(url, params).then (result) ->
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    return () ->
        return {"users": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgUsersResources", Resource)
