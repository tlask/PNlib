within PNlib.Examples.DisTest;
model SinglePD
  extends Modelica.Icons.Example;

  PNlib.PD P1 annotation(Placement(visible = true, transformation(origin={0,0},      extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  inner PNlib.Settings settings annotation(Placement(visible = true, transformation(origin={30,30},    extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  annotation(Diagram(coordinateSystem(extent={{-40,-40},
            {40,40}},                                                                                                    preserveAspectRatio = true, initialScale = 0.1, grid = {2, 2})), experiment(StartTime=0.0, StopTime=1.0));
end SinglePD;
