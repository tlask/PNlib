within PNlib.PN.Examples.ExtTest;
model TDSdiscrete
  extends Modelica.Icons.Example;
  inner PNlib.PN.Components.Settings settings annotation(Placement(transformation(extent={{20, 20}, {40, 40}})));
  PNlib.PN.Components.PD P1(nOut=1, startTokens= 18) annotation(Placement(transformation(extent={{-40, -10}, {-20, 10}})));
  PNlib.PN.Components.PD P2(nIn=1) annotation(Placement(transformation(extent={{20, -10}, {40, 10}})));
  PNlib.PN.Components.TS T1(distributionType = PNlib.Types.DistributionType.Discrete,localSeed=1, nIn=1, nOut=1) annotation(Placement(transformation(extent={{-10, -10}, {10, 10}})));
equation
  connect(T1.outPlacesDis[1], P2.inTransitionDis[1]) annotation(
    Line(points = {{4, 0}, {18, 0}, {18, 0}, {20, 0}}, thickness = 0.5));
  connect(P1.outTransitionDis[1], T1.inPlacesDis[1]) annotation(
    Line(points = {{-20, 0}, {-4, 0}, {-4, 0}, {-4, 0}}, thickness = 0.5));
  annotation(Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-40, -40}, {40, 40}})), experiment(StartTime=0.0, StopTime=60.0, Tolerance = 1e-6));
end TDSdiscrete;
