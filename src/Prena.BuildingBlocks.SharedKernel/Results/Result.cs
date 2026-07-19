namespace Prena.BuildingBlocks.SharedKernel.Results;


public record Error(
    string Code,
    string Description
);



public class Result
{

    public bool IsSuccess { get; }

    public Error? Error { get; }


    protected Result(
        bool success,
        Error? error)
    {
        IsSuccess = success;
        Error = error;
    }


    public static Result Success()
        => new(true,null);


    public static Result Failure(Error error)
        => new(false,error);

}
