within PNlib.PN.Components;
model TS "Stochastic Transition"
  parameter Integer nIn = 0 "number of input places" annotation(Dialog(connectorSizing=true));
  parameter Integer nOut = 0 "number of output places" annotation(Dialog(connectorSizing=true));
  parameter Integer nInExt = 0 "number of input places" annotation(Dialog(connectorSizing=true));
  //****MODIFIABLE PARAMETERS AND VARIABLES BEGIN****//
  parameter PNlib.Types.StoTimeType timeType=PNlib.Types.StoTimeType.Delay;
  parameter PNlib.Types.DistributionType distributionType=PNlib.Types.DistributionType.Exponential
    "distribution type of delay" annotation(Dialog(enable = true, group = "Distribution"));
  parameter  Real h=1
    "probability density" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Exponential then true else false, group = "Exponential distribution"));
  parameter  Real a=0
    "Lower Limit" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Triangular or distributionType==PNlib.Types.DistributionType.Uniform or distributionType==PNlib.Types.DistributionType.TruncatedNormal then true else false, group = "Triangular, Uniform or Truncated normal distribution"));
  parameter Real b=1
    "Upper Limit" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Triangular or distributionType==PNlib.Types.DistributionType.Uniform or distributionType==PNlib.Types.DistributionType.TruncatedNormal then true else false, group = "Triangular, Uniform or Truncated normal distribution"));
  parameter Real c=0.5
    "Most likely value" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Triangular then true else false, group = "Triangular distribution"));
  parameter Real mu=0.5
    "Expected value" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.TruncatedNormal then true else false, group = "Truncated normal distribution"));
  parameter Real sigma=1/6
    "Standard deviation" annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.TruncatedNormal then true else false, group = "Truncated normal distribution"));
  parameter Real E[:]={1, 2, 3, 4, 5, 6} "Events of Discrete Distribution"
    annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Discrete  then true else false, group = "Discrete Probability Distribution"));
  parameter Real P[:]={1/6, 1/6, 1/6, 1/6, 1/6, 1/6} "Probability of Discrete Distribution"
    annotation(Dialog(enable = if distributionType==PNlib.Types.DistributionType.Discrete  then true else false, group = "Discrete Probability Distribution"));
  Integer arcWeightIntIn[nIn] = fill(1, nIn) "arc weights of input places" annotation(Dialog(enable = true, group = "Arc Weights"));
  Integer arcWeightIntOut[nOut] = fill(1, nOut) "arc weights of output places" annotation(Dialog(enable = true, group = "Arc Weights"));
  Boolean firingCon=true "additional firing condition" annotation(Dialog(enable = true, group = "Firing Condition"));
  Boolean active;
  parameter Integer localSeed = PNlib.Functions.Random.counter() "Local seed to initialize random number generator" annotation(Dialog(enable = true, group = "Random Number Generator"));
  //****MODIFIABLE PARAMETERS AND VARIABLES END****//
  discrete Real putFireTime "putative firing time at event";
  discrete Real putTime "putative Dealy or Duration";
protected
  discrete Integer state128[4] "state of random number generator";
  Real r128 "random number";
  outer PNlib.PN.Components.Settings settings "global settings for animation and display";
  Integer tIntIn[nIn] "integer tokens of input places (for generating events!)";
  Integer tIntOut[nOut]
    "integer tokens of output places (for generating events!)";
  Integer minTokensInt[nIn]
    "Integer minimum tokens of input places (for generating events!)";
  Integer maxTokensInt[nOut]
    "Integer maximum tokens of output places (for generating events!)";
  Boolean enableIn[nIn] "Is the transition enabled by input places?";
  Boolean enableOut[nOut] "Is the transition enabled by output places?";
  Boolean extendedCondition[nInExt] "Is the extended Arc Condition true?";
  Boolean allExtendedCondition =PNlib.Functions.OddsAndEnds.allTrue(extendedCondition) "Are all the extended Arc Condition true?" ;
  //****BLOCKS BEGIN****// since no events are generated within functions!!!
  PN.Blocks.activationDisIn activationIn(nIn=nIn, tIntIn=tIntIn, arcWeightIntIn=arcWeightIntIn, minTokensInt=minTokensInt, firingCon=firingCon);
  PN.Blocks.activationDisOut activationOut(nOut=nOut, tIntOut=tIntOut, arcWeightIntOut=arcWeightIntOut, maxTokensInt=maxTokensInt, firingCon=firingCon);

  PN.Blocks.delay fireDelay (nIn=nIn, nOut=nOut, delay=putTime, active=active and allExtendedCondition, firingCon=firingCon, enabledIn=enabledIn.value, enabledOut=enabledOut.value) if  timeType==PNlib.Types.StoTimeType.Delay;
  PN.Blocks.duration fireDuration (nIn=nIn, nOut=nOut, duration=putTime, activeIn=activationIn.active, activeOut=activationOut.active, firingCon=firingCon, enabledIn=enabledIn.value, enabledOut=enabledOut.value) if  timeType==PNlib.Types.StoTimeType.FireDuration;
  PN.Blocks.eventSto fireEvent (nIn=nIn, nOut=nOut, event=putFireTime, active=active, firingCon=firingCon, enabledIn=enabledIn.value, enabledOut=enabledOut.value) if  timeType==PNlib.Types.StoTimeType.Event;
  //****BLOCKS END****//
public
  Boolean TimeOver;
  //Boolean active "Is the transition active?";
  //Boolean fire "Does the transition fire?";
  PNlib.PN.Interfaces.DisTransitionIn inPlacesDis[nIn](
    each active=timePassedIn.value,
    arcWeightint=arcWeightIntIn,
    each fire=fireIn.value,
    tint=tIntIn,
    minTokensint=minTokensInt,
    enable=enableIn) if nIn > 0 "connector for input places" annotation(Placement(transformation(extent={{-56, -10}, {-40, 10}}, rotation=0)));
  PNlib.PN.Interfaces.DisTransitionOut outPlacesDis[nOut](
    each active=timePassedOut.value,
    arcWeightint=arcWeightIntOut,
    each fire=fireOut.value,
    each enabledByInPlaces=if nIn>0 and not timeType==PNlib.Types.StoTimeType.FireDuration then enabledIn.value else true,
    tint=tIntOut,
    maxTokensint=maxTokensInt,
    enable=enableOut) if nOut > 0 "connector for output places" annotation(Placement(transformation(extent={{40, -10}, {56, 10}}, rotation=0)));
  PNlib.PN.Interfaces.TransitionInExt extIn[nInExt](
        condition=extendedCondition) if nInExt > 0 "connector for output extended Arcs" annotation(Placement(transformation(extent={{-56, 80}, {-40, 100}}, rotation =0)));
  // Enable
    PNlib.PN.Interfaces.BooleanConIn enabledIn1(value=PNlib.Functions.OddsAndEnds.allTrue(enableIn)) if nIn>0;
    PNlib.PN.Interfaces.BooleanConIn enabledOut1(value=PNlib.Functions.OddsAndEnds.allTrue(enableOut)) if nOut>0;
    PNlib.PN.Interfaces.BooleanConIn enabledIn2(value=false) if nIn==0;
    PNlib.PN.Interfaces.BooleanConIn enabledOut2(value=false) if nOut==0;
    PNlib.PN.Interfaces.BooleanConOut enabledIn;
    PNlib.PN.Interfaces.BooleanConOut enabledOut;
  // Delay
    PNlib.PN.Interfaces.BooleanConIn fireInDelay(value=fireDelay.fire) if  timeType==PNlib.Types.StoTimeType.Delay;
    PNlib.PN.Interfaces.BooleanConIn fireOutDelay(value=fireDelay.fire) if  timeType==PNlib.Types.StoTimeType.Delay;
    PNlib.PN.Interfaces.BooleanConIn timePassedInDelay(value=fireDelay.delayPassed) if  timeType==PNlib.Types.StoTimeType.Delay;
    PNlib.PN.Interfaces.BooleanConIn timePassedOutDelay(value=fireDelay.delayPassed) if  timeType==PNlib.Types.StoTimeType.Delay;
  // Duration
    PNlib.PN.Interfaces.BooleanConIn fireInDuration(value=fireDuration.fireIn) if  timeType==PNlib.Types.StoTimeType.FireDuration;
    PNlib.PN.Interfaces.BooleanConIn fireOutDuration(value=fireDuration.fireOut) if  timeType==PNlib.Types.StoTimeType.FireDuration;
    PNlib.PN.Interfaces.BooleanConIn timePassedInDuration(value=fireDuration.durationPassedIn) if  timeType==PNlib.Types.StoTimeType.FireDuration;
    PNlib.PN.Interfaces.BooleanConIn timePassedOutDuration(value=fireDuration.durationPassedOut) if  timeType==PNlib.Types.StoTimeType.FireDuration;
    PNlib.PN.Interfaces.BooleanConIn TransitionDurationFire (value=fireDuration.fire) if  timeType==PNlib.Types.StoTimeType.FireDuration;
  // Event
    PNlib.PN.Interfaces.BooleanConIn fireInEvent(value=fireEvent.fire) if  timeType==PNlib.Types.StoTimeType.Event;
    PNlib.PN.Interfaces.BooleanConIn fireOutEvent(value=fireEvent.fire) if  timeType==PNlib.Types.StoTimeType.Event;
    PNlib.PN.Interfaces.BooleanConIn timePassedInEvent(value=fireEvent.eventPassed) if  timeType==PNlib.Types.StoTimeType.Event;
    PNlib.PN.Interfaces.BooleanConIn timePassedOutEvent(value=fireEvent.eventPassed) if  timeType==PNlib.Types.StoTimeType.Event;
  // Dummy
    PNlib.PN.Interfaces.BooleanConOut fireIn;
    PNlib.PN.Interfaces.BooleanConOut fireOut;
    PNlib.PN.Interfaces.BooleanConOut timePassedIn;
    PNlib.PN.Interfaces.BooleanConOut timePassedOut;
equation
  active=activationIn.active and activationOut.active and allExtendedCondition;
// Enable
  connect(enabledIn,enabledIn1);
  connect(enabledIn,enabledIn2);
  connect(enabledOut,enabledOut1);
  connect(enabledOut,enabledOut2);
// Delay
  connect(fireIn,fireInDelay);
  connect(fireOut,fireOutDelay);
  connect(timePassedIn,timePassedInDelay);
  connect(timePassedOut,timePassedOutDelay);
// Duration
  connect(fireIn,fireInDuration);
  connect(fireOut,fireOutDuration);
  connect(timePassedIn,timePassedInDuration);
  connect(timePassedOut,timePassedOutDuration);
// Event
  connect(fireIn,fireInEvent);
  connect(fireOut,fireOutEvent);
  connect(timePassedIn,timePassedInEvent);
  connect(timePassedOut,timePassedOutEvent);

   //****ERROR MESSENGES BEGIN****//
   for i in 1:nIn loop
      assert(arcWeightIntIn[i]>=0, "Input arc weights must be positive.");
   end for;
   for i in 1:nOut loop
      assert(arcWeightIntOut[i]>=0, "Output arc weights must be positive.");
   end for;


   assert(h>0 or distributionType<>PNlib.Types.DistributionType.Exponential, "The probability density must be greater than zero");
   assert((a<b and a<=c and c<=b) or distributionType<>PNlib.Types.DistributionType.Triangular, "The Lower Limit must be less than or equal to the Most likely value and the Most likely value must be less than or equal to the Upper Limit but he Lower Limit must be less than the Upper Limit");
   assert(a<b or distributionType<>PNlib.Types.DistributionType.Uniform, "The Lower Limit must be less than the Upper Limit");
   assert(PNlib.Functions.OddsAndEnds.isEqual(sum(P), 1.0, 1e-6) or distributionType<>PNlib.Types.DistributionType.Discrete, "The Probability sum Probability of Discrete Distribution has to be equal to 1");
   assert(size(E,1)==size(P,1) or distributionType<>PNlib.Types.DistributionType.Discrete, "Discrete probability distribution must have the same number of events and probabilities");
   //****ERROR MESSENGES END****//
 algorithm
    //****MAIN BEGIN****//
    TimeOver:= timeType==PNlib.Types.StoTimeType.Event and time>=putFireTime;
   //generate random putative fire time according to Next-Reaction method of Gibson and Bruck
   when pre(fireOut.value) or pre(TimeOver) then    //17.06.11 Reihenfolge getauscht!
     (r128, state128) := Modelica.Math.Random.Generators.Xorshift128plus.random(pre(state128));
     if distributionType==PNlib.Types.DistributionType.Exponential then
         putTime := PNlib.Functions.Random.randomexp(h, r128);
     elseif distributionType==PNlib.Types.DistributionType.Triangular then
         putTime := PNlib.Functions.Random.randomtriangular(a, b, c, r128);
     elseif distributionType==PNlib.Types.DistributionType.Uniform then
         putTime := Modelica.Math.Distributions.Uniform.quantile( max(r128,10 ^ (-10)), a, b);
     elseif distributionType==PNlib.Types.DistributionType.TruncatedNormal then
         putTime := Modelica.Math.Distributions.TruncatedNormal.quantile( max(r128,10 ^ (-10)), a, b, mu, sigma);
     else
         putTime := max(PNlib.Functions.Random.randomdis(E, P, r128),1e-6);
     end if;
     putFireTime:=time + putTime;
   end when;

    //****MAIN END****//
 initial equation
   //to initialize the random generator otherwise the first random number is always the same in every simulation run
   if distributionType==PNlib.Types.DistributionType.Exponential then
       putTime = PNlib.Functions.Random.randomexp(h, r128);
   elseif distributionType==PNlib.Types.DistributionType.Triangular then
       putTime = PNlib.Functions.Random.randomtriangular(a, b, c, r128);
   elseif distributionType==PNlib.Types.DistributionType.Uniform then
       putTime = Modelica.Math.Distributions.Uniform.quantile( max(r128,10 ^ (-10)), a, b);
   elseif distributionType==PNlib.Types.DistributionType.TruncatedNormal then
       putTime = Modelica.Math.Distributions.TruncatedNormal.quantile( max(r128,10 ^ (-10)), a, b, mu, sigma);
   else
       putTime = max(PNlib.Functions.Random.randomdis(E, P, r128),1e-6);
   end if;
   putFireTime=time + putTime;
 initial algorithm
   // Generate initial state from localSeed and globalSeed
   state128 := Modelica.Math.Random.Generators.Xorshift128plus.initialState(localSeed, settings.globalSeed);
   (r128, state128) := Modelica.Math.Random.Generators.Xorshift128plus.random(
       state128);
  annotation(defaultComponentName = "T1", Icon(graphics={Rectangle(
          extent={{-40, 100}, {40, -100}},
          lineColor={0, 0, 0},
        fillColor={0, 0, 0},
        fillPattern=FillPattern.Solid),
        Text(
        origin = {-3, 8},
        lineColor = {255, 255, 255},
        fillColor = {255, 255, 255},
        extent = {{-35, 42}, {43, -52}},
        textString = "S"),
        Text(
          extent={{-2, -112}, {-2, -140}},
          lineColor={0, 0, 0},
          textString=DynamicSelect("%timeType","%timeType")),
        Text(
          extent={{-2, -152}, {-2, -180}},
          lineColor={0, 0, 0},
          textString=DynamicSelect("%distributionType","%distributionType")),
        Text(
          extent={{-4, 139}, {-4, 114}},
          lineColor={0, 0, 0},
          textString="%name")}), Diagram(graphics));

end TS;
