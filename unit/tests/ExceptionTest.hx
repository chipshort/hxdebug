package tests;

import debug.Data;

class ExceptionTest extends ServerTest
{
    public function testGlobalException() : Void
    {
        var data : ExceptionData = main.debugData.pop();

        assertEquals("Error, testing", data.error);
    }
}