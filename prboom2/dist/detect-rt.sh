#!/bin/bash
# detect GPU and set up emulated ray tracing (AMD RX 5000 and below) if needed

detect_rt_capability() {
  VULKANINFO=$(vulkaninfo --summary 2>/dev/null || vulkaninfo 2>/dev/null)

  RAY_TRACING_SUPPORTED=$(echo "$VULKANINFO" | grep -c "rayTracingPipeline.*= true")
  ACCEL_STRUCT_SUPPORTED=$(echo "$VULKANINFO" | grep -c "VK_KHR_acceleration_structure")

  if [ "$RAY_TRACING_SUPPORTED" -gt 0 ] && [ "$ACCEL_STRUCT_SUPPORTED" -gt 0 ]; then
    # ray tracing is supported natively or already emulated
    return 0
  fi

  DEVICE_NAME=$(echo "$VULKANINFO" | grep "deviceName" | head -1)
  IS_RADV=$(echo "$DEVICE_NAME" | grep -i "RADV")

  if [ -n "$IS_RADV" ]; then
    # check for pre-RT AMD GPU (Navi 1x = pre-RT, Navi 2x/3x = RT-capable)
    IS_PRE_RT=$(echo "$DEVICE_NAME" | grep -iE "NAVI1[0-4]|VEGA|POLARIS|R9 |RX 5[0-9][0-9]|RX 4[0-9][0-9]")

    if [ -n "$IS_PRE_RT" ]; then
      echo "Detected pre-RT AMD GPU. Enabling emulated ray tracing..."
      export RADV_EXPERIMENTAL=emulate_rt
      # fallback for Mesa < 24.2.0
      export RADV_PERFTEST=emulate_rt
      return 0
    fi
  fi

  # check if AMDVLK
  IS_AMDVLK=$(echo "$DEVICE_NAME" | grep -i "AMDVLK")
  if [ -n "$IS_AMDVLK" ] && [ "$RAY_TRACING_SUPPORTED" -eq 0 ]; then
    echo "AMDVLK detected but no ray tracing support found."
    echo "Try installing RADV (Mesa) for emulated ray tracing support."
    return 1
  fi

  return 0
}

detect_rt_capability
RT_OK=$?

if [ $RT_OK -ne 0 ]; then
  echo "Warning: Could not find a Vulkan device with ray tracing support."
fi
