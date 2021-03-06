component extends="tests.InjectableTest" {

    public void function setUp() {
        variables.fw = new framework.one();
        injectMethod( variables.fw, this, 'isFrameworkInitialized', 'isFrameworkInitialized' );
        variables.fwVars = getVariablesScope( variables.fw );
        variables.fwVars.framework.resourceRouteTemplates = [
            { method = 'default', httpMethods = [ '$GET' ] },
            { method = 'new', httpMethods = [ '$GET' ], routeSuffix = '/new' },
            { method = 'create', httpMethods = [ '$POST' ] },
            { method = 'show', httpMethods = [ '$GET' ], includeId = true },
            { method = 'update', httpMethods = [ '$PUT','$PATCH' ], includeId = true },
            { method = 'destroy', httpMethods = [ '$DELETE' ], includeId = true }
        ];
        variables.fwVars.framework.routes = [
            { 'hint' = 'Standard Route', '$GET/old/path' = '/new/path' },
            { 'hint' = 'Resource Routes', '$RESOURCES' = 'dogs' }
        ];
    }

    public void function testProcessRoutes() {

        request._fw1.cgiRequestMethod = 'GET';

        var routeMatch = variables.fw.processRoutes( '/no/match', variables.fw.getRoutes() );
        assertFalse( routeMatch.matched );

        routeMatch = variables.fw.processRoutes( '/old/path/foo', variables.fw.getRoutes() );
        assertTrue( routeMatch.matched );
        assertEquals( '/new/path/foo/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

        routeMatch = variables.fw.processRoutes( '/dogs/42', variables.fw.getRoutes() );
        assertTrue( routeMatch.matched );
        assertEquals( '/dogs/show/id/42/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

        request._fw1.cgiRequestMethod = 'PUT';

        routeMatch = variables.fw.processRoutes( '/dogs/42', variables.fw.getRoutes() );
        assertTrue( routeMatch.matched );
        assertEquals( '/dogs/update/id/42/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

    }
    
    public void function testProcessRoutesExplicit() {

        request._fw1.cgiRequestMethod = 'FOO';

        var routeMatch = variables.fw.processRoutes( '/no/match', variables.fw.getRoutes(), 'GET' );
        assertFalse( routeMatch.matched );

        routeMatch = variables.fw.processRoutes( '/old/path/foo', variables.fw.getRoutes(), 'GET' );
        assertTrue( routeMatch.matched );
        assertEquals( '/new/path/foo/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

        routeMatch = variables.fw.processRoutes( '/dogs/42', variables.fw.getRoutes(), 'GET' );
        assertTrue( routeMatch.matched );
        assertEquals( '/dogs/show/id/42/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

        routeMatch = variables.fw.processRoutes( '/dogs/42', variables.fw.getRoutes(), 'PUT' );
        assertTrue( routeMatch.matched );
        assertEquals( '/dogs/update/id/42/', rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target ) );

    }
    
    // PRIVATE

    private boolean function isFrameworkInitialized() {
        return false;
    }
}
