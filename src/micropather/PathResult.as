//
// micropather

package micropather {

public class PathResult
{
    public static const SOLVED :String = "solved";
    public static const NO_SOLUTION :String = "noSolution";
    public static const START_END_SAME :String = "startEndSame";

    public function get resultType () :String { return _resultType; }

    /** The Array of nodes that make up the path, if the pathfinding was successful */
    public function get path () :Array { return _path; }

    /** True if this PathResult contains a successful path */
    public function get isSolution () :Boolean { return _resultType == SOLVED; }

    /** The first node in the path */
    public function get start () :* { return _path[0]; }
    /** The last node in the path */
    public function get end () :* { return _path[_path.length - 1]; }

    internal static function solved (path :Array) :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = SOLVED;
        out._path = path;
        return out;
    }

    internal static function noSolution () :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = NO_SOLUTION;
        return out;
    }

    internal static function startEndSame () :PathResult {
        var out :PathResult = new PathResult();
        out._resultType = START_END_SAME;
        return out;
    }

    private var _resultType :String;
    private var _path :Array;
}
}
