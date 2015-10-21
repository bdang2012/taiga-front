describe "UserService", ->
    userService = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}
        mocks.resources.users = {
            getProjects: sinon.stub(),
            getContacts: sinon.stub()
        }

        provide.value "tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()

            return null

    _inject = (callback) ->
        inject (_tgUserService_, _$q_, _$rootScope_) ->
            userService = _tgUserService_
            $q = _$q_
            $rootScope = _$rootScope_

    beforeEach ->
        module "taigaCommon"
        _mocks()
        _inject()

    it "get user contacts", () ->
        userId = 2

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getContacts.withArgs(userId).returns(true)

        expect(userService.getContacts(userId)).to.be.true

    it "attach user contacts to projects", (done) ->
        userId = 2

        projects = Immutable.fromJS([
            {id: 1, members: [1, 2, 3]},
            {id: 2, members: [2, 3]},
            {id: 3, members: [1]}
        ])

        contacts = Immutable.fromJS([
            {id: 1, name: "fake1"},
            {id: 2, name: "fake2"},
            {id: 3, name: "fake3"}
        ])

        mocks.resources.users.getContacts = sinon.stub()
        mocks.resources.users.getContacts.withArgs(userId).promise().resolve(contacts)

        userService.attachUserContactsToProjects(userId, projects).then (_projects_) ->
            contacts = _projects_.get(0).get("contacts")

            expect(contacts.get(0).get("name")).to.be.equal('fake1')

            done()

    it "get user contacts", (done) ->
        userId = 2

        contacts = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        mocks.resources.users.getContacts = sinon.stub()
        mocks.resources.users.getContacts.withArgs(userId).promise().resolve(contacts)

        userService.getContacts(userId).then (_contacts_) ->
            expect(_contacts_).to.be.eql(contacts)
            done()

        $rootScope.$apply()

    it "get user by username", (done) ->
        username = "username-1"

        user = {id: 1}

        mocks.resources.users.getUserByUsername = sinon.stub()
        mocks.resources.users.getUserByUsername.withArgs(username).promise().resolve(user)

        userService.getUserByUserName(username).then (_user_) ->
            expect(_user_).to.be.eql(user)
            done()
