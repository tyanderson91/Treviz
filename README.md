# TREVIZ
### _Trajectory Evaluation and Visualization_
Treviz is an application for Mac that enables design, analysis, and visualization of flight vehicle trajectories and missions. It is intended for students, researchers, and anyone interested in the performance of air and space vehicles. The name comes from Golan Trevize, a character from Isaac Asimov's _Foundation_ series who had a special computer that let him see paths through the stars. I hope that this app can make spaceflight analysis easy and fun.
![Example Analysis](/Resources/Screenshot Example.png)
## Installation
Treviz currently exists as a project built for Xcode 11 and MacOS Catalina. Plans for the future include hosting for free on the Mac App store.
## Structure
The model structure for a Treviz analysis extists in the "Model" folder. They key components of the model are as listed below.
### Analysis
Treviz is a Document-based app. The base document is an Analysis, and the extension for the analysis filetype is .asys. An analysis consists of a complete set of input states, phase transitions, vehicle definitions, guidance options, and output sets. A single window (or tab, using the document-based architecture) represents one analysis.
### Phase (NOT YET IMPLEMENTED)
A trajectory phase is defined by a single vehicle, a set of initial conditions, guidance or control to manipulate the vehicle along its trajectory, and a terminal condition. One or more initial state variables can be taken from the vehicle's previous mission phase, but the state must be fully defined. Once a phase reaches its terminal condition the vehicle transitions to the next phase. The analysis is complete once the last phase has terminated. Different vehicles can be analyzed at the same time using parallel phases.
### Variable
Variables are the basic currency of a Treviz analysis. Each variable represents one numerical aspect of the vehicle state, whether basic (position, velocity, mass) or derived (altitude, angle-of-attack, propellant mass fraction). Basic variables are calculated and updated at each point in a trajectory in order to fully define the vehicle state, while derived variables can be calculated real time as inputs into the force model (e.g. angle-of-attack dependent aerodynamics) or at the end of analysis for plotting. Variables can have a single value or a list of values representing an entire phase. Each variable has a unique Variable ID, a string identifier for use in configuration files and for representation internally to the app. Variables also have names, a symbolic representation, and associatied units (distance, time, mass, etc.)
### State
A state is simply a collection of all the variables that represent the vehicle state. It serves as a useful container to pass a whole trajectory around the different modules in the app.
### Output
An output is all the configurations needed to produce a single piece of analysis information at the end of a trajectory. An output can take the form of either text or a plot.
* Text outputs are printed sequentially in the text output view, and can also be automatically saved to a text or .csv file (NOT YET IMPLEMENTED).
* Plot outputs can take several forms, including single or multiple lines, points, or contours. Plot appearance is highly customizable, both in application defaults and on a per-plot basis. (NOT YET IMPLEMENTED). Plots are presented using the CorePlot framework.
### Parameter (NOT YET IMPLEMENTED)
Parameter is a protocol that is used by all variables as well as any configurable settings. Parameters are what makes trade studies possible. For instance, an analysis could compare several trajectories with different initial heights. In this case, initial height would be a parameter, and the varying heights would be parameter settings. You can also use categorical settings as parameters, such as comparing a flat-earth approximation to round earth, or comparing an explicit solver to a Runge-Kutta integration scheme. All outputs are made with parameters (including variables), but categorical parameters can only be used as categories in outputs
### Condition
Conditions can be used for both ending a trajectory phase (Terminal Condition) and as options in outputs. Conditions are formed with one or more sub-conditions, which are tests against a particular variable value. Some examples of conditions are:
* y<10 AND 0<t<50
* x = 100
* h = local maximum
An analysis has a list of Conditions that can be added and used for any purpose. Conditions can also be created temporarily for specific purposes, such as template terminal conditions (e.g. "Departed from Sphere of Influence") or for specific outputs (e.g. "Max Q")
### Vehicle (NOT YET IMPLEMENTED)
A vehicle include all the masses (dry, primary propellant, etc), aerodynamic configurations, and GNC capabilities that determine the forces on the vehicle at a given point in time. A vehicle can fly along one trajectory phase at a time. Vehicles can also include CAD models, drawings, or basic shapes to help with visualization or to automatically calculate mass and inertia.
### Attachments (NOT YET IMPLEMENTED)
Attachments are connections between vehicles along a particular trajetory phase. They allow different vehicles to influence each other in specific ways while minimizing the computation power needed for the attached vehicle. For example an attachment of a second stage to a first stage launch vehicle could allow the analysis to run against the first stage state only, while accounting for the added mass, inertia, and aerodynamic forces of the second stage. Similarly, the second stage could accumulate a heat load while riding along with the first stage. Attachments can be designed te break at specific conditions or at the end of the primary vehicle's phase, at which point the attached vehicle may continue its own path on a new parallel trajectory if desired.
### Celestial Body (NOT YET IMPLEMENTED)
A Celestial Body is any planet, moon, or other natural object that can exert a gravitational influence on a vehicle. Celestial bodies include a range of possible gravity models (constant acceleration, point mass, spherhical harmonics, etc.), atmosphere models (exponential, table lookup), and ephemerides (real, flat, circularized). For most analysis types, one celestial body must be chosen to anchor the central coordinate system. The chosen central body can change with different trajectory phases.
### Geometry (NOT YET IMPLEMENTED)
Three geometry objects exist to provide differetn ways of looking at existing data: Coordinate Systems, Vectors, and Points
* Coordinate Systems are automatically created at the center of each vehicle and each celestial body. Coordinate systems can also be defined by a point and two vectors. Any vector-type variable can be plotted against any coordinate system
* Vectors are lines between any two points. They can be used to anchor camera views, and they can be used in derived outputs
* Points are automatically created at the origin of each coordinate system. They can also be defined in relation to existing coordinate systems or placed at the surface of a celestial body

## Future Plans
* Re-write the model layer in C++ so it can be ported to other platforms
* Extend to iPad and iPhone for visualization
* Add in C++ code inter-operability for Guidance, Navigation, Control, and custom physics modules
* Add an optimization module
* Make template analysis types (e.g. Low Earth Orbit, atmospheric entry, satellite demise analysis, launch vehicle )
* Have ability to perform GNC calculations on a separate attached computer, e.g. Raspberry Pi
