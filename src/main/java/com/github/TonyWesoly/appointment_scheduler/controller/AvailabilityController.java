package com.github.TonyWesoly.appointment_scheduler.controller;

import com.github.TonyWesoly.appointment_scheduler.dto.AvailabilityDto;
import com.github.TonyWesoly.appointment_scheduler.model.Availability;
import com.github.TonyWesoly.appointment_scheduler.service.AvailabilityService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/slots")
public class AvailabilityController {

    private final AvailabilityService availabilityService;

    public AvailabilityController(AvailabilityService newavailabilityService) {
        availabilityService = newavailabilityService;
    }

    @GetMapping
    public ResponseEntity<List<AvailabilityDto>> getSlots(){
        List<AvailabilityDto> allDtos = availabilityService.findAll();
        return ResponseEntity.ok(allDtos);
    }

    @PostMapping
    public ResponseEntity<AvailabilityDto> createSlot(@RequestBody AvailabilityDto dto){
        AvailabilityDto dtoWithEntityId =  availabilityService.save(dto);
        return ResponseEntity.status(201).body(dtoWithEntityId);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSlot(@PathVariable Long id){
        availabilityService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
