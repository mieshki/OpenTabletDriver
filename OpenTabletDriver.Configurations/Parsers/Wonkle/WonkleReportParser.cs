using System.Diagnostics.CodeAnalysis;
using OpenTabletDriver.Plugin.Tablet;

namespace OpenTabletDriver.Configurations.Parsers.Wonkle
{
    [DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicParameterlessConstructor)]
    public class WonkleReportParser : IReportParser<IDeviceReport>
    {
        private const int InRangeBit = 1;

        public IDeviceReport Parse(byte[] report)
        {
            TabletReport tr;
            if (report[1].IsBitSet(InRangeBit))
                tr = new TabletReport(report);
            else if (report.Length > 2 && report[2].IsBitSet(InRangeBit))
                tr = new TabletReport(report[1..]);
            else
                return new OutOfRangeReport(report);

            tr.PenButtons[0] = false;
            return tr;
        }
    }
}
