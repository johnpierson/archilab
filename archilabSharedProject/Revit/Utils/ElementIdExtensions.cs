using Autodesk.Revit.DB;

namespace archilab.Revit.Utils
{
    /// <summary>
    /// Extension methods for ElementId to support both IntegerValue (pre-2026) and Value (2026+).
    /// </summary>
    public static class ElementIdExtensions
    {
        /// <summary>
        /// Returns the integer value of the ElementId. Uses Value in Revit 2026+, IntegerValue otherwise.
        /// </summary>
        public static int GetIdValue(this ElementId id)
        {
#if Revit2026
            return (int)id.Value;
#else
            return id.IntegerValue;
#endif
        }
    }
}
