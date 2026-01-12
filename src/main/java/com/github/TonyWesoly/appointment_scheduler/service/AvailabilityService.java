package com.github.TonyWesoly.appointment_scheduler.service;

import com.github.TonyWesoly.appointment_scheduler.dto.AvailabilityDto;
import com.github.TonyWesoly.appointment_scheduler.model.Availability;
import com.github.TonyWesoly.appointment_scheduler.repository.AvailabilityRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class AvailabilityService {
    private final AvailabilityRepository availabilityRepository;

    private AvailabilityDto mapToDto(Availability entity){
        return new AvailabilityDto(
                entity.getId(),
                entity.getDayOfWeek(),
                entity.getStartTime(),
                entity.getEndTime()
        );
    }

    private Availability mapToEntity(AvailabilityDto availabilityDto){
        return new Availability(
                availabilityDto.getDayOfWeek(),
                availabilityDto.getStartTime(),
                availabilityDto.getEndTime()
        );
    }

    public AvailabilityService(AvailabilityRepository availabilityRepository) {
        this.availabilityRepository = availabilityRepository;
    }

    public List<AvailabilityDto> findAll(){
        List<Availability> entities = availabilityRepository.findAll();
        List<AvailabilityDto> dtos= new ArrayList<>();
        for (Availability availability : entities){
            AvailabilityDto dto = mapToDto(availability);
            dtos.add(dto);
        }
        return dtos;
    }

    public AvailabilityDto save(AvailabilityDto dto) {
        Availability entity = mapToEntity(dto);
        Availability savedEntity = availabilityRepository.save(entity);

        //return new dto with ID
        return mapToDto(savedEntity);
    }

    public AvailabilityDto findById(Long id){
        // lambda because of "Lazy Evaluation"
        Availability entity = availabilityRepository.findById(id).orElseThrow(() ->
                new EntityNotFoundException("Avability entity not found with id:" + id));
        return mapToDto(entity);
    }

    public void deleteById(Long id){
        availabilityRepository.deleteById(id);
    }
}
