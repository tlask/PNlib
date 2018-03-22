within PNlib.PN.Examples.ExtTest;
model TESTest
  extends Modelica.Icons.Example;
  inner PNlib.PN.Components.Settings settings annotation(Placement(transformation(extent={{20, 20}, {40, 40}})));
  PNlib.PN.Components.PD P1(nInDis = 1, nOutDis = 1, startTokens= 1) annotation(Placement(visible = true, transformation(extent = {{-48, -20}, {-28, 0}}, rotation = 0)));
  PNlib.PN.Components.PD P2(nInDis=1) annotation(Placement(visible = true, transformation(extent = {{12, -20}, {32, 0}}, rotation = 0)));
  PNlib.PN.Components.TD T2( nOutDis = 1, timeType = PNlib.Types.TimeType.Event,timeValue = {3, 4, 5, 9})  annotation(
    Placement(visible = true, transformation(origin = {-66, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  PNlib.PN.Components.TS T1(distributionType = PNlib.Types.DistributionType.Triangular, nInDis = 1, nOutDis = 1, timeType = PNlib.Types.StoTimeType.Event)  annotation(
    Placement(visible = true, transformation(origin = {-8, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(T1.outPlacesDis[1], P2.inTransitionDis[1]) annotation(
    Line(points = {{-4, -10}, {10, -10}, {10, -10}, {12, -10}}, thickness = 0.5));
  connect(P1.outTransitionDis[1], T1.inPlacesDis[1]) annotation(
    Line(points = {{-28, -10}, {-12, -10}, {-12, -10}, {-12, -10}}, thickness = 0.5));
  connect(T2.outPlacesDis[1], P1.inTransitionDis[1]) annotation(
    Line(points = {{-62, -10}, {-50, -10}, {-50, -10}, {-48, -10}}, thickness = 0.5));
  annotation(Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-80, -40}, {40, 40}})), experiment(StartTime=0.0, StopTime=10.0, Tolerance = 1e-6));
end TESTest;
