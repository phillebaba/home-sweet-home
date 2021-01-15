#define PWM_IN       8  // Input PWM signal from motherboard
#define PWM_OUT      11 // Output PWM signal to fan

#define NUM_SAMPLES  32 // Look at x samples and average them to compute the PWM duty cycle and frequency
#define PWM_OFFSET   35 // Duty cycle that will be set if the PWM_IN signal is at 0%
#define MIN_DUTY_CYCLE 130

#define TIMEOUT      2000000 // Timeout counter limit.  If we exceed this number of microseconds without seeing an edge,
                             // assume the PWM has been set to 100% (if timeout high) or 0% (if timeout low)
                             // 2000000 microseconds = 2 seconds - the timeout needs to be greater than our delay count.

int PWMinState, prevInState;
unsigned long highTime[NUM_SAMPLES], lowTime[NUM_SAMPLES], pulseStart, pulseEnd;
unsigned long currentTime, highTimeOut, lowTimeOut;
int highTimerHit, lowTimerHit;
unsigned long highSum = 0;
unsigned long totalSum = 0;
unsigned long dutyCycle = 0;
unsigned long PWM_out_dutycycle;
int PWM_OUT_value;

void setup() {
  pinMode(PWM_IN, INPUT);

  // Start serial port for debug output
  Serial.begin(9600);
  Serial.print("Initializing...\n");

  // Set the PWM frequency for the PWM_OUT pin to the base frequency 31.25 kHz
  setPwmFrequency(PWM_OUT, 1);

  // Write initial PWM
  analogWrite(PWM_OUT, 150);

  // Initialize the timeout counters to 0
  highTimeOut = 0;
  lowTimeOut = 0;
  highTimerHit = 0;
  lowTimerHit = 0;

  // Read an initial value to get things started.
  prevInState = digitalRead(PWM_IN);
}

void loop() {
  int count;

  PWMinState = digitalRead(PWM_IN);

  if ((PWMinState == HIGH) && (prevInState == LOW)) {
    // Detected a rising edge on PWM_IN
    pulseStart = micros();
    highTimeOut = pulseStart;

    // Gather the next NUM_SAMPLES number of data points and calculate the PWM duty cycle and frequency
    for (count = 0; count < NUM_SAMPLES; count++) {
      while (digitalRead(PWM_IN) == HIGH) {
        // Sit in the while loop until we see a low and we'll just check the timeout counter
        currentTime = micros();
        if (currentTime < highTimeOut) {
          // The internal counter must have wrapped around, so we'll just reset the highTimeOut time
          highTimeOut = currentTime;
        } else if ((currentTime - highTimeOut) > TIMEOUT) {
          highTimerHit = 1;
          count = NUM_SAMPLES;  // Force us out of the for loop
          break;                // Break out of the while loop
        }
      }
      pulseEnd = micros();
      highTime[count] = pulseEnd - pulseStart;
      lowTimeOut = pulseEnd;

      while (digitalRead(PWM_IN) == LOW) {
        // Now we sit in the while loop until we see a high and we'll just check the timeout counter
        currentTime = micros();
        if (currentTime < lowTimeOut) {
          // The internal counter must have wrapped around, so we'll just reset the lowTimeOut time
          lowTimeOut = currentTime;
        } else if ((currentTime - lowTimeOut) > TIMEOUT) {
          lowTimerHit = 1;
          count = NUM_SAMPLES;  // Force us out of the for loop
          break;                // Break out of the while loop
        }
      }
      pulseStart = micros();
      lowTime[count] = pulseStart - pulseEnd;
      highTimeOut = pulseStart;
    }

    // Calculate the PWM duty cycle and frequency
    highSum = 0;
    totalSum = 0;
    dutyCycle = 0;

    if (highTimerHit == 1) {
      Serial.print("HIGH Timeout hit in loop - assumeing PWM_IN = 100%\n");
      dutyCycle = 100;
      highTimerHit = 0;       // Reset the timeout variables
      highTimeOut = micros();
    } else if (lowTimerHit == 1) {
      Serial.print("Low Timeout hit in loop - assumeing PWM_IN = 0%\n");
      dutyCycle = 0;
      lowTimerHit = 0;        // Reset the timeout variables
      lowTimeOut = micros();
    } else {
      for (count = 0; count < NUM_SAMPLES; count++) {
        highSum += highTime[count];
        totalSum += highTime[count] + lowTime[count];
      }
      dutyCycle = highSum * 100 / totalSum;
      Serial.print("Duty Cycle = High Time (");
      Serial.print(highSum);
      Serial.print(") / Total Time (");
      Serial.print(totalSum);
      Serial.print(") = ");
      Serial.print(dutyCycle);
      Serial.print("\n");
    }

    PWM_out_dutycycle = dutyCycle;
    if (PWM_out_dutycycle < MIN_DUTY_CYCLE) {
      PWM_out_dutycycle = MIN_DUTY_CYCLE;
    }
    Serial.print("Output PWM Duty Cycle Value = ");
    Serial.print(PWM_out_dutycycle);
    Serial.print("\n");

    PWM_OUT_value = PWM_out_dutycycle;
    analogWrite(PWM_OUT, PWM_OUT_value);
    delay(1000);
  } else if ((PWMinState == LOW) && (prevInState == HIGH)) {
    // Falling edge on PWM_IN
    lowTimeOut = micros();
  } else if (PWMinState == HIGH) {
    // If we don't see a transition, we'll just check the timeout counter
    currentTime = micros();
    if (currentTime < highTimeOut) {
      // The internal counter must have wrapped around, so we'll just reset the highTimeOut time
      highTimeOut = currentTime;
    } else if ((currentTime - highTimeOut) > TIMEOUT) {
      Serial.print("HIGH Timeout hit out of loop - assumeing PWM_IN = 100%\n");
      PWM_out_dutycycle = 100;
      Serial.print("Output PWM Duty Cycle Value = ");
      Serial.print(PWM_out_dutycycle);
      Serial.print("\n");
      PWM_OUT_value = PWM_out_dutycycle;
      analogWrite(PWM_OUT, PWM_OUT_value);

      highTimerHit = 0;       // Reset the timeout variables
      highTimeOut = micros();
    }
  } else if (PWMinState == LOW) {
    // If we don't see a transition, we'll just check the timeout counter
    currentTime = micros();
    if (currentTime < lowTimeOut) {
      // The internal counter must have wrapped around, so we'll just reset the lowTimeOut time
      lowTimeOut = currentTime;
    } else if ((currentTime - lowTimeOut) > TIMEOUT) {
      Serial.print("LOW Timeout hit out of loop - assumeing PWM_IN = 0%\n");
      dutyCycle = 0;
      PWM_out_dutycycle = dutyCycle;
      if (PWM_out_dutycycle < MIN_DUTY_CYCLE) {
        PWM_out_dutycycle = MIN_DUTY_CYCLE;
      }
      Serial.print("Output PWM Duty Cycle Value = ");
      Serial.print(PWM_out_dutycycle);
      Serial.print("\n");

      PWM_OUT_value = PWM_out_dutycycle;
      analogWrite(PWM_OUT, PWM_OUT_value);

      lowTimerHit = 0;       // Reset the timeout variables
      lowTimeOut = micros();
    }
  }

  prevInState = PWMinState;
}

/**
 * Divides a given PWM pin frequency by a divisor.
 *
 * The resulting frequency is equal to the base frequency divided by
 * the given divisor:
 *   - Base frequencies:
 *      o The base frequency for pins 3, 9, 10, and 11 is 31250 Hz.
 *      o The base frequency for pins 5 and 6 is 62500 Hz.
 *   - Divisors:
 *      o The divisors available on pins 5, 6, 9 and 10 are: 1, 8, 64,
 *        256, and 1024.
 *      o The divisors available on pins 3 and 11 are: 1, 8, 32, 64,
 *        128, 256, and 1024.
 *
 * PWM frequencies are tied together in pairs of pins. If one in a
 * pair is changed, the other is also changed to match:
 *   - Pins 5 and 6 are paired on timer0
 *   - Pins 9 and 10 are paired on timer1
 *   - Pins 3 and 11 are paired on timer2
 *
 * Note that this function will have side effects on anything else
 * that uses timers:
 *   - Changes on pins 3, 5, 6, or 11 may cause the delay() and
 *     millis() functions to stop working. Other timing-related
 *     functions may also be affected.
 *   - Changes on pins 9 or 10 will cause the Servo library to function
 *     incorrectly.
 *
 * Thanks to macegr of the Arduino forums for his documentation of the
 * PWM frequency divisors. His post can be viewed at:
 *   http://forum.arduino.cc/index.php?topic=16612#msg121031
 */
void setPwmFrequency(int pin, int divisor) {
  byte mode;
  if(pin == 5 || pin == 6 || pin == 9 || pin == 10) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 64: mode = 0x03; break;
      case 256: mode = 0x04; break;
      case 1024: mode = 0x05; break;
      default: return;
    }
    if(pin == 5 || pin == 6) {
      TCCR0B = TCCR0B & 0b11111000 | mode;
    } else {
      TCCR1B = TCCR1B & 0b11111000 | mode;
    }
  } else if(pin == 3 || pin == 11) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 32: mode = 0x03; break;
      case 64: mode = 0x04; break;
      case 128: mode = 0x05; break;
      case 256: mode = 0x06; break;
      case 1024: mode = 0x7; break;
      default: return;
    }
    TCCR2B = TCCR2B & 0b11111000 | mode;
  }
}

