using System;
using System.Collections.Generic;
using System.Linq;
using Dynamo.Graph.Nodes;
using Revit.Elements;
using RevitServices.Persistence;
using archilab.Revit.Utils;
// ReSharper disable UnusedMember.Global

namespace archilab.Revit.Elements
{
    /// <summary>
    /// 
    /// </summary>
    public class FilterRule
    {
        internal Autodesk.Revit.DB.FilterRule InternalFilterRule { get; set; }

        internal FilterRule()
        {
        }

        internal FilterRule(Autodesk.Revit.DB.FilterRule fr)
        {
            InternalFilterRule = fr;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="categories"></param>
        /// <param name="parameterName"></param>
        /// <param name="ruleType"></param>
        /// <param name="parameterValue"></param>
        /// <returns></returns>
        [NodeCategory("Action")]
        public static FilterRule CreateRule(List<Category> categories, string parameterName, string ruleType, object parameterValue)
        {
            var doc = DocumentManager.Instance.CurrentDBDocument;
            var catIds = categories.Select(x => new Autodesk.Revit.DB.ElementId(x.Id)).ToList();

            // (Fixes #87) Resolve the parameter from the categories' filterable parameters instead of
            // sampling an element of the first category, so rules can be built before any elements
            // of those categories exist in the model (project templates, container models).
            if (!TryResolveParameter(doc, catIds, parameterName, out var elementId, out var storageType))
                throw new Exception("Parameter with given name doesn't exist for all Categories.");

            switch (ruleType)
            {
                case "equals":
                    switch (storageType)
                    {
                        case Autodesk.Revit.DB.StorageType.Integer:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEqualsRule(elementId,
                                    Convert.ToInt32(parameterValue)));
                        case Autodesk.Revit.DB.StorageType.Double:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEqualsRule(elementId,
                                    Convert.ToDouble(parameterValue), 0.001));
                        case Autodesk.Revit.DB.StorageType.String:
#if Revit2026
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEqualsRule(elementId,
                                    parameterValue.ToString()));
#else
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEqualsRule(elementId,
                                    parameterValue.ToString(), true));
#endif
                        case Autodesk.Revit.DB.StorageType.ElementId:
                            return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEqualsRule(
                                elementId, new Autodesk.Revit.DB.ElementId(((Element)parameterValue).Id)));
                        default:
                            return null;
                    }
                case "does not equal":
                    switch (storageType)
                    {
                        case Autodesk.Revit.DB.StorageType.Integer:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEqualsRule(elementId,
                                    Convert.ToInt32(parameterValue)));
                        case Autodesk.Revit.DB.StorageType.Double:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEqualsRule(elementId,
                                    Convert.ToDouble(parameterValue), 0.001));
                        case Autodesk.Revit.DB.StorageType.String:
#if Revit2026
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEqualsRule(elementId,
                                    parameterValue.ToString()));
#else
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEqualsRule(elementId,
                                    parameterValue.ToString(), true));
#endif
                        case Autodesk.Revit.DB.StorageType.ElementId:
                            return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEqualsRule(
                                elementId, new Autodesk.Revit.DB.ElementId(((Element)parameterValue).Id)));
                        default:
                            return null;
                    }
                case "is greater than":
                    switch (storageType)
                    {
                        case Autodesk.Revit.DB.StorageType.Integer:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterRule(elementId,
                                    Convert.ToInt32(parameterValue)));
                        case Autodesk.Revit.DB.StorageType.Double:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterRule(elementId,
                                    Convert.ToDouble(parameterValue), 0.001));
                        case Autodesk.Revit.DB.StorageType.String:
#if Revit2026
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterRule(elementId,
                                    parameterValue.ToString()));
#else
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterRule(elementId,
                                    parameterValue.ToString(), true));
#endif
                        case Autodesk.Revit.DB.StorageType.ElementId:
                            return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterRule(
                                elementId, new Autodesk.Revit.DB.ElementId(((Element)parameterValue).Id)));
                        default:
                            return null;
                    }
                case "is greater than or equal to":
                    switch (storageType)
                    {
                        case Autodesk.Revit.DB.StorageType.Integer:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterOrEqualRule(elementId,
                                    Convert.ToInt32(parameterValue)));
                        case Autodesk.Revit.DB.StorageType.Double:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterOrEqualRule(elementId,
                                    Convert.ToDouble(parameterValue), 0.001));
                        case Autodesk.Revit.DB.StorageType.String:
#if Revit2026
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterOrEqualRule(elementId,
                                    parameterValue.ToString()));
#else
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterOrEqualRule(elementId,
                                    parameterValue.ToString(), true));
#endif
                        case Autodesk.Revit.DB.StorageType.ElementId:
                            return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateGreaterOrEqualRule(
                                elementId, new Autodesk.Revit.DB.ElementId(((Element)parameterValue).Id)));
                        default:
                            return null;
                    }
                case "is less than":
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessRule(elementId,
                            Convert.ToInt32(parameterValue)));
                case "is less than or equal to":
                    switch (storageType)
                    {
                        case Autodesk.Revit.DB.StorageType.Integer:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessOrEqualRule(elementId,
                                    Convert.ToInt32(parameterValue)));
                        case Autodesk.Revit.DB.StorageType.Double:
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessOrEqualRule(elementId,
                                    Convert.ToDouble(parameterValue), 0.001));
                        case Autodesk.Revit.DB.StorageType.String:
#if Revit2026
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessOrEqualRule(elementId,
                                    parameterValue.ToString()));
#else
                            return new FilterRule(
                                Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessOrEqualRule(elementId,
                                    parameterValue.ToString(), true));
#endif
                        case Autodesk.Revit.DB.StorageType.ElementId:
                            return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateLessOrEqualRule(
                                elementId, new Autodesk.Revit.DB.ElementId(((Element)parameterValue).Id)));
                        default:
                            return null;
                    }
                case "contains":
#if Revit2026
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateContainsRule(elementId,
                            parameterValue.ToString()));
#else
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateContainsRule(elementId,
                            parameterValue.ToString(), true));
#endif
                case "does not contain":
#if Revit2026
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotContainsRule(elementId,
                            parameterValue.ToString()));
#else
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotContainsRule(elementId,
                            parameterValue.ToString(), true));
#endif
                case "begins with":
#if Revit2026
                    return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateBeginsWithRule(elementId,
                        parameterValue.ToString()));
#else
                    return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateBeginsWithRule(elementId,
                        parameterValue.ToString(), true));
#endif
                case "does not begin with":
#if Revit2026
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotBeginsWithRule(elementId,
                            parameterValue.ToString()));
#else
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotBeginsWithRule(elementId,
                            parameterValue.ToString(), true));
#endif
                case "ends with":
#if Revit2026
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEndsWithRule(elementId,
                            parameterValue.ToString()));
#else
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateEndsWithRule(elementId,
                            parameterValue.ToString(), true));
#endif
                case "does not end with":
#if Revit2026
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEndsWithRule(elementId,
                            parameterValue.ToString()));
#else
                    return new FilterRule(
                        Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateNotEndsWithRule(elementId,
                            parameterValue.ToString(), true));
#endif
#if !Revit2019
                case "has a value":
                    return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateHasValueParameterRule(elementId));
                case "has no value":
                    return new FilterRule(Autodesk.Revit.DB.ParameterFilterRuleFactory.CreateHasNoValueParameterRule(elementId));
#endif
                default:
                    return null;
            }
        }

#region Utilities

        private static bool TryResolveParameter(Autodesk.Revit.DB.Document doc,
            ICollection<Autodesk.Revit.DB.ElementId> catIds, string parameterName,
            out Autodesk.Revit.DB.ElementId parameterId, out Autodesk.Revit.DB.StorageType storageType)
        {
            parameterId = Autodesk.Revit.DB.ElementId.InvalidElementId;
            storageType = Autodesk.Revit.DB.StorageType.None;

            var filterable = Autodesk.Revit.DB.ParameterFilterUtilities.GetFilterableParametersInCommon(doc, catIds);
            if (filterable == null || filterable.Count == 0) return false;

            if (Enum.TryParse<Autodesk.Revit.DB.BuiltInParameter>(parameterName, out var bip))
            {
                var bipId = new Autodesk.Revit.DB.ElementId(bip);
                if (!filterable.Contains(bipId)) return false;

                parameterId = bipId;
                storageType = doc.get_TypeOfStorage(bip);
                return true;
            }

            // Match project/shared parameters by name first, then built-in parameters by their label.
            foreach (var id in filterable)
            {
                if (!(doc.GetElement(id) is Autodesk.Revit.DB.ParameterElement pe) || pe.Name != parameterName)
                    continue;

                parameterId = id;
                storageType = GetStorageType(pe);
                return true;
            }

            foreach (var id in filterable)
            {
                if (doc.GetElement(id) is Autodesk.Revit.DB.ParameterElement) continue;

                var builtIn = (Autodesk.Revit.DB.BuiltInParameter)id.GetIdValue();
                string label;
                try { label = Autodesk.Revit.DB.LabelUtils.GetLabelFor(builtIn); }
                catch { continue; }
                if (label != parameterName) continue;

                parameterId = id;
                storageType = doc.get_TypeOfStorage(builtIn);
                return true;
            }

            return false;
        }

        private static Autodesk.Revit.DB.StorageType GetStorageType(Autodesk.Revit.DB.ParameterElement pe)
        {
            var definition = pe.GetDefinition();
#if Revit2019 || Revit2020 || Revit2021
            switch (definition.ParameterType)
            {
                case Autodesk.Revit.DB.ParameterType.Text:
                case Autodesk.Revit.DB.ParameterType.URL:
                    return Autodesk.Revit.DB.StorageType.String;
                case Autodesk.Revit.DB.ParameterType.YesNo:
                case Autodesk.Revit.DB.ParameterType.Integer:
                    return Autodesk.Revit.DB.StorageType.Integer;
                case Autodesk.Revit.DB.ParameterType.Material:
                case Autodesk.Revit.DB.ParameterType.FamilyType:
                case Autodesk.Revit.DB.ParameterType.Image:
                    return Autodesk.Revit.DB.StorageType.ElementId;
                default:
                    return Autodesk.Revit.DB.StorageType.Double;
            }
#else
            var dataType = definition.GetDataType();
            if (dataType == Autodesk.Revit.DB.SpecTypeId.String.Text ||
                dataType == Autodesk.Revit.DB.SpecTypeId.String.Url)
                return Autodesk.Revit.DB.StorageType.String;
            if (dataType == Autodesk.Revit.DB.SpecTypeId.Boolean.YesNo ||
                dataType == Autodesk.Revit.DB.SpecTypeId.Int.Integer)
                return Autodesk.Revit.DB.StorageType.Integer;
            if (Autodesk.Revit.DB.Category.IsBuiltInCategory(dataType) ||
                dataType == Autodesk.Revit.DB.SpecTypeId.Reference.Material ||
                dataType == Autodesk.Revit.DB.SpecTypeId.Reference.Image)
                return Autodesk.Revit.DB.StorageType.ElementId;
            return Autodesk.Revit.DB.StorageType.Double;
#endif
        }

#endregion
    }
}
