###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/team/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

module = angular.module("taigaTeam")

#############################################################################
##  Inventory Controller
#############################################################################

class InventoryController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$q",
        "$location",
        "$tgNavUrls",
        "tgAppMetaService",
        "$tgAuth",
        "$translate",
        "tgProjectService",
        "tgCurrentUserService"
    ]

    constructor: (@scope, @rootscope, @repo, @rs, @params, @q, @location, @navUrls, @appMetaService, @auth,
                  @translate, @projectService,@currentUserService) ->
        @scope.sectionName = "TEAM.SECTION_NAME"

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            title = @translate.instant("TEAM.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("TEAM.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    setRole: (role) ->
        if role
            @scope.filtersRole = role
        else
            @scope.filtersRole = null

    loadMembers: ->
        currentUser = @auth.getUser()

        if currentUser? and not currentUser.photo?
            currentUser.photo = "/images/unnamed.png"

        memberships = @projectService.project.toJS().memberships

        @scope.currentUser = _.find memberships, (membership) =>
            return currentUser? and membership.user == currentUser.id

        @scope.totals = {}

        _.forEach memberships, (membership) =>
            @scope.totals[membership.user] = 0

        @scope.memberships = _.filter memberships, (membership) =>
            if membership.user && (not currentUser? or membership.user != currentUser.id)
                return membership

        @scope.memberships = _.filter memberships, (membership) => return membership.is_active

        for membership in @scope.memberships
            if not membership.photo?
                membership.photo = "/images/unnamed.png"

    loadInventoryBinhDang: ->
        currentUser = @auth.getUser()

        if currentUser? and not currentUser.photo?
            currentUser.photo = "/images/unnamed.png"

        inventory = @currentUserService.inventory.get("all").toJS()

        @scope.totals = {}

        _.forEach inventory, (membership) =>
            @scope.totals[membership.user] = 0
  
        ### binh blocked 
        @scope.inventory = _.filter inventory, (membership) =>
            if membership.user && (not currentUser? or membership.user != currentUser.id)
                return membership 
        ###
                
        @scope.inventory = _.filter inventory, (membership) => return membership.is_active

        for membership in @scope.inventory
            if not membership.photo?
                membership.photo = "/images/unnamed.png"    

        console.log 'bdlog: line 124 main.coffee @scope.inventory'
        console.log @scope.inventory

        
        console.log 'bdlog: line 127 main.coffee for @scope.inveotoryRoles'
        @scope.inventoryRoles = @currentUserService.inventory.get("all").toJS()
        console.log @scope.inventoryRoles

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit('project:loaded', project)

            @scope.issuesEnabled = project.is_issues_activated
            @scope.tasksEnabled = project.is_kanban_activated or project.is_backlog_activated
            @scope.wikiEnabled = project.is_wiki_activated

            return project

    loadMemberStats: ->
        return @rs.projects.memberStats(@scope.projectId).then (stats) =>
          totals = {}
          _.forEach @scope.totals, (total, userId) =>
              vals = _.map(stats, (memberStats, statsKey) -> memberStats[userId])
              total = _.reduce(vals, (sum, el) -> sum + el)
              @scope.totals[userId] = total

          @scope.stats = @.processStats(stats)
          @scope.stats.totals = @scope.totals

    processStat: (stat) ->
        max = _.max(stat)
        min = _.min(stat)
        singleStat = _.map stat, (value, key) ->
            if value == min
                return [key, 0.1]
            if value == max
                return [key, 1]
            return [key, (value * 0.5) / max]
        singleStat = _.object(singleStat)
        return singleStat

    processStats: (stats) ->
        for key,value of stats
            stats[key] = @.processStat(value)
        return stats

    loadInitialData: ->
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.users, project.roles)
            @.loadMembers()
            @.loadInventoryBinhDang()

            return @.loadMemberStats()

module.controller("InventoryController", InventoryController)


#############################################################################
## Inventory Filters Directive
#############################################################################

InventoryFiltersDirective = () ->
    return {
        templateUrl: "team/inventory-filter.html"
    }

module.directive("tgInventoryFilters", [InventoryFiltersDirective])


#############################################################################
## Inventory Directive
#############################################################################

InventoryMembersDirective = () ->
    template = "team/inventory-members.html"

    return {
        templateUrl: template
        scope: {
            memberships: "=",
            filtersQ: "=filtersq",
            filtersRole: "=filtersrole",
            stats: "="
            issuesEnabled: "=issuesenabled"
            tasksEnabled: "=tasksenabled"
            wikiEnabled: "=wikienabled"
        }
    }

module.directive("tgInventoryMembers", InventoryMembersDirective)
