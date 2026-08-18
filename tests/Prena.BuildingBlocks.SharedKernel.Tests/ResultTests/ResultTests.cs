using Prena.BuildingBlocks.SharedKernel.Results;


namespace Prena.BuildingBlocks.SharedKernel.Tests.ResultTests;


public class ResultTests
{


    [Fact]
    public void Success_Result_Should_Be_Successful()
    {

        var result = Result.Success();


        Assert.True(result.IsSuccess);

        Assert.Null(result.Error);

    }



    [Fact]
    public void Failure_Result_Should_Contain_Error()
    {

        var error = new Error(
            "TEST_ERROR",
            "Test error");


        var result =
            Result.Failure(error);



        Assert.False(result.IsSuccess);

        Assert.Equal(
            error,
            result.Error);

    }

}
